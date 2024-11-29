import Combine

extension SecureConversations {
    final class PendingInteraction: ObservableObject {
        @Published private(set) var pendingStatus = false
        @Published private(set) var unreadMessageCount = 0
        @Published private(set) var hasPendingInteraction = false
        private let environment: Environment
        private(set) var pendingStatusCancellationToken: String?
        private(set) var unreadMessageCountCancellationToken: String?

        init(environment: Environment) {
            self.environment = environment
            self.pendingStatusCancellationToken = environment.observePendingSecureConversationsStatus { [weak self] result in
                guard let self else { return }
                // At this point it is enough to know if there is a pending conversation,
                // so no need to handle error.
                pendingStatus = (try? result.get()) ?? false
            }
            self.unreadMessageCountCancellationToken = environment.observeSecureConversationsUnreadMessageCount { [weak self] result in
                guard let self else { return }
                // At this point it is enough to know if there is an unread message count,
                // so no need to handle error.
                unreadMessageCount = (try? result.get()) ?? 0
            }

            $pendingStatus.combineLatest($unreadMessageCount)
                .map { hasPending, unreadCount in
                    hasPending || unreadCount > 0
                }
                .assign(to: &$hasPendingInteraction)
        }

        deinit {
            if let unreadMessageCountCancellationToken {
                environment.unsubscribeFromUnreadCount(unreadMessageCountCancellationToken)
            }

            if let pendingStatusCancellationToken {
                environment.unsubscribeFromPendingStatus(pendingStatusCancellationToken)
            }
        }
    }
}

extension SecureConversations.PendingInteraction {
    struct Environment {
        var observePendingSecureConversationsStatus: CoreSdkClient.ObservePendingSecureConversationStatus
        var observeSecureConversationsUnreadMessageCount: CoreSdkClient.SubscribeForUnreadSCMessageCount
        var unsubscribeFromUnreadCount: CoreSdkClient.UnsubscribeFromUnreadCount
        var unsubscribeFromPendingStatus: CoreSdkClient.UnsubscribeFromPendingSCStatus
    }
}

extension SecureConversations.PendingInteraction.Environment {
    init(with client: CoreSdkClient) {
        self.observePendingSecureConversationsStatus = client.observePendingSecureConversationStatus
        self.observeSecureConversationsUnreadMessageCount = client.subscribeForUnreadSCMessageCount
        self.unsubscribeFromPendingStatus = client.unsubscribeFromPendingSecureConversationStatus
        self.unsubscribeFromUnreadCount = client.unsubscribeFromUnreadCount
    }
}

#if DEBUG
extension SecureConversations.PendingInteraction.Environment {
    static let mock = Self(
        observePendingSecureConversationsStatus: { _ in nil },
        observeSecureConversationsUnreadMessageCount: { _ in nil },
        unsubscribeFromUnreadCount: { _ in },
        unsubscribeFromPendingStatus: { _ in }
    )
}

extension SecureConversations.PendingInteraction {
    static func mock(environment: Environment = .mock) -> Self {
        .init(environment: environment)
    }
}
#endif
