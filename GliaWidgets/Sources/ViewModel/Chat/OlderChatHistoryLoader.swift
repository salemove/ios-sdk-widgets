import Foundation
@_spi(GliaWidgets) internal import GliaCoreSDK

/// Loads older pages of chat history for the chat and transcript models, keeping at most one
/// request in flight. Holds the key for the next older page; the Core SDK keeps no paging state.
/// Used from the main thread only, like the chat and transcript models that own it.
final class OlderChatHistoryLoader {
    struct Environment {
        var fetchOlderChatHistory: CoreSdkClient.FetchOlderChatHistory
        var log: CoreSdkClient.Logger
        @Dependency(\.widgets.openTelemetry) var openTelemetry: OpenTelemetry
    }

    private let environment: Environment
    private(set) var olderPage: CoreSdkClient.OlderChatHistoryPage?
    private(set) var isLoading = false
    /// Bumped whenever the key is replaced from outside a load, so a load that was in flight
    /// meanwhile cannot prepend items or write back a key that no longer matches the history.
    private var generation = 0
    /// The pull-to-load request started by `loadOlderItems`, so tests can wait for it.
    private(set) var currentLoad: Task<Void, Never>?

    init(environment: Environment) {
        self.environment = environment
    }

    var canLoad: Bool {
        olderPage != nil
    }

    var canStartLoading: Bool {
        !isLoading && canLoad
    }

    /// Replaces the key after a full history load, or after taking over another model's history.
    func replaceOlderPage(_ olderPage: CoreSdkClient.OlderChatHistoryPage?) {
        generation += 1
        isLoading = false
        self.olderPage = olderPage
    }

    /// The outcome of loading one older page.
    enum LoadOutcome {
        /// The older messages, oldest first. The next key is stored.
        case loaded([ChatMessage])
        /// The request failed. The current key is kept, so the next pull retries the same page.
        case failed
        /// `replaceOlderPage` was called while the request was in flight, so the result was dropped.
        case superseded
    }

    /// Loads the next older page. Returns `nil` without fetching when a load is already in flight
    /// or nothing older exists.
    @MainActor
    func load() async -> LoadOutcome? {
        guard let request = startLoading() else { return nil }
        return await finishLoading(request)
    }

    private struct LoadRequest {
        let olderPage: CoreSdkClient.OlderChatHistoryPage
        let generation: Int
    }

    /// Marks a load as in flight before any suspension, so a second pull in the same run loop
    /// cannot start another request.
    private func startLoading() -> LoadRequest? {
        guard canStartLoading, let olderPage else { return nil }
        isLoading = true
        return LoadRequest(olderPage: olderPage, generation: generation)
    }

    @MainActor
    private func finishLoading(_ request: LoadRequest) async -> LoadOutcome {
        let result: Result<CoreSdkClient.ChatHistoryPage, Error>
        do {
            result = .success(try await environment.fetchOlderChatHistory(request.olderPage))
        } catch {
            result = .failure(error)
        }
        guard request.generation == generation else { return .superseded }
        isLoading = false
        switch result {
        case let .success(page):
            olderPage = page.olderPage
            return .loaded(page.messages)
        case let .failure(error):
            environment.log.warning("Older chat history load failed: \(error)")
            return .failed
        }
    }
}

extension OlderChatHistoryLoader {
    /// Loads the next older page and prepends the messages not shown yet to `section`, reporting
    /// the refresh control state and the prepended rows through `action`, as both the chat and
    /// transcript models need.
    /// - Parameters:
    ///   - knownMessageIds: Uppercased ids of the messages already shown, so they are not added again.
    ///   - makeItem: Builds the chat item for an older message, or returns `nil` to skip it.
    ///   - didPrependMessages: Called with the older messages that were not known before.
    func loadOlderItems(
        into section: Section<ChatItem>,
        knownMessageIds: @escaping () -> Set<String>,
        makeItem: @escaping (ChatMessage) -> ChatItem?,
        didPrependMessages: @escaping ([ChatMessage]) -> Void = { _ in },
        action: @escaping (ChatViewModel.Action) -> Void
    ) {
        guard let request = startLoading() else { return }
        environment.openTelemetry.logger.i(.chatScreenHistoryLoading)
        action(.olderHistoryStateUpdated(canLoad: true, isLoading: true))
        currentLoad = Task { @MainActor [weak self, weak section] in
            guard let self else { return }
            let outcome = await finishLoading(request)
            guard let section else { return }
            switch outcome {
            case .superseded:
                return
            case .failed:
                break
            case let .loaded(messages):
                environment.openTelemetry.logger.i(.chatScreenHistoryLoaded) {
                    $0[.messageCount] = .string("\(messages.count)")
                }
                let known = knownMessageIds()
                let olderMessages = messages.filter { !known.contains($0.id.uppercased()) }
                didPrependMessages(olderMessages)
                let items = olderMessages.compactMap(makeItem)
                if !items.isEmpty {
                    section.prepend(items)
                    action(.prependRows(items.count, to: section.index))
                }
            }
            action(.olderHistoryStateUpdated(canLoad: canLoad, isLoading: false))
        }
    }
}

extension OlderChatHistoryLoader.Environment {
    static func create(with environment: ChatViewModel.Environment) -> Self {
        .init(
            fetchOlderChatHistory: environment.fetchOlderChatHistory,
            log: environment.log
        )
    }

    static func create(with environment: SecureConversations.TranscriptModel.Environment) -> Self {
        .init(
            fetchOlderChatHistory: environment.fetchOlderChatHistory,
            log: environment.log
        )
    }
}
