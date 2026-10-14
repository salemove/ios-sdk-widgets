import Foundation
import GliaCoreSDK

/// Loads older pages of chat history for the chat and transcript models, keeping at most one
/// request in flight. Holds the key for the next older page; the Core SDK keeps no paging state.
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

    /// Calls `completion` with the older messages, oldest first, or with `nil` on failure. Stores
    /// the next key on success and keeps the current one on failure, so the next pull retries the
    /// same page. Does nothing when a load is already in flight or nothing older exists, and drops
    /// the result if `replaceOlderPage` was called while the request was in flight.
    func load(_ completion: @escaping ([ChatMessage]?) -> Void) {
        guard canStartLoading, let olderPage else { return }
        isLoading = true
        let loadGeneration = generation
        environment.fetchOlderChatHistory(olderPage) { [weak self] result in
            guard let self, loadGeneration == generation else { return }
            isLoading = false
            switch result {
            case let .success(page):
                self.olderPage = page.olderPage
                completion(page.messages)
            case let .failure(error):
                environment.log.warning("Older chat history load failed: \(error)")
                completion(nil)
            }
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
        guard canStartLoading else { return }
        environment.openTelemetry.logger.i(.chatScreenHistoryLoading)
        action(.olderHistoryStateUpdated(canLoad: true, isLoading: true))
        load { [weak self, weak section] messages in
            guard let self, let section else { return }
            if let messages {
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
