import Foundation

/// Loads older pages of chat history for the chat and transcript models, keeping at most one
/// request in flight. Holds the key for the next older page; the Core SDK keeps no paging state.
final class OlderChatHistoryLoader {
    struct Environment {
        var fetchOlderChatHistory: CoreSdkClient.FetchOlderChatHistory
        var log: CoreSdkClient.Logger
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
