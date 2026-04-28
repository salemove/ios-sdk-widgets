import Foundation
import Combine

extension SecureConversations {
    final class PendingInteraction: ObservableObject {
        @Published private(set) var pendingStatus = false
        @Published private(set) var unreadMessageCount = 0
        @Published private(set) var hasPendingInteraction = false
        @Published private(set) var hasTransferredSecureConversation = false
        private let environment: Environment
        private var pendingStatusTask: Task<Void, Never>?
        private var unreadMessageCountTask: Task<Void, Never>?
        private var activeInteractor: Interactor?
        private var cancelBag = CancelBag()

        init(environment: Environment) throws {
            self.environment = environment
            observePendingStatus()
            observeUnreadMessageCount()

            let interactorStatePublisher = environment.interactorPublisher
                .flatMap { interactor -> AnyPublisher<InteractorState, Never> in
                    guard let interactor else {
                        return Just(.none).eraseToAnyPublisher()
                    }
                    return interactor.$state.eraseToAnyPublisher()
                }
            let currentEngagementPublisher = environment.interactorPublisher
                .flatMap { interactor -> AnyPublisher<CoreSdkClient.Engagement?, Never> in
                    guard let interactor else {
                        return Just(nil).eraseToAnyPublisher()
                    }
                    return interactor.$currentEngagement.eraseToAnyPublisher()
                }
            let hasOngoingOrEnqueueingEngagement = Publishers.CombineLatest(interactorStatePublisher, currentEngagementPublisher)
                .map { state, currentEngagement in
                    if case .engaged = currentEngagement?.status {
                        return true
                    } else {
                        return state.enqueueingEngagementKind != nil
                    }
                }

            currentEngagementPublisher
                .map { $0?.isTransferredSecureConversation ?? false }
                .assign(to: &$hasTransferredSecureConversation)

            $pendingStatus.combineLatest(
                $unreadMessageCount, $hasTransferredSecureConversation, hasOngoingOrEnqueueingEngagement
            )
            .map { hasPending, unreadCount, hasTransferredSecureConversation, hasOngoingOrEnqueueingEngagement in
                (hasPending || unreadCount > 0 || hasTransferredSecureConversation) && !hasOngoingOrEnqueueingEngagement
            }
            .assign(to: &$hasPendingInteraction)
        }

        deinit {
            unreadMessageCountTask?.cancel()
            pendingStatusTask?.cancel()
        }
    }
}

extension SecureConversations.PendingInteraction {
    private func observePendingStatus() {
        pendingStatusTask = Task { [weak self] in
            guard let self else { return }
            do {
                for try await value in environment.observePendingSecureConversationsStatus() {
                    await MainActor.run { [weak self] in
                        self?.pendingStatus = value
                    }
                }
            } catch is CancellationError {
                return
            } catch {
                await MainActor.run { [weak self] in
                    self?.pendingStatus = false
                }
            }
        }
    }

    private func observeUnreadMessageCount() {
        unreadMessageCountTask = Task { [weak self] in
            guard let self else { return }
            do {
                for try await count in environment.observeSecureConversationsUnreadMessageCount() {
                    await MainActor.run { [weak self] in
                        self?.unreadMessageCount = count ?? 0
                    }
                }
            } catch is CancellationError {
                return
            } catch {
                await MainActor.run { [weak self] in
                    self?.unreadMessageCount = 0
                }
            }
        }
    }
}

extension SecureConversations.PendingInteraction {
    struct Environment {
        var observePendingSecureConversationsStatus: CoreSdkClient.SecureConversations.ObservePendingStatus
        var observeSecureConversationsUnreadMessageCount: CoreSdkClient.SecureConversations.SubscribeForUnreadMessageCount
        var interactorPublisher: AnyPublisher<Interactor?, Never>
    }
}

extension SecureConversations.PendingInteraction {
    enum Error: Swift.Error {
        enum Subscription {
            case unreadMessageCount
            case pendingStatus
        }
        case subscriptionFailure(Subscription)
    }
}

extension SecureConversations.PendingInteraction.Environment {
    init(
        client: CoreSdkClient,
        interactorPublisher: AnyPublisher<Interactor?, Never>
    ) {
        self.observePendingSecureConversationsStatus = client.secureConversations.observePendingStatus
        self.observeSecureConversationsUnreadMessageCount = client.secureConversations.subscribeForUnreadMessageCount
        self.interactorPublisher = interactorPublisher
    }
}

#if DEBUG
@_spi(GliaWidgets) import GliaCoreSDK
extension SecureConversations.PendingInteraction.Environment {
    static let mock: Self = {
        let uuidGen = UUID.incrementing
        return Self(
            observePendingSecureConversationsStatus: { AsyncThrowingStream { $0.finish() } },
            observeSecureConversationsUnreadMessageCount: { AsyncThrowingStream { $0.finish() } },
            interactorPublisher: .mock(.mock())
        )
    }()
}

extension SecureConversations.PendingInteraction {
    static func mock(environment: Environment = .mock) throws -> Self {
        try .init(environment: environment)
    }
}
#endif
