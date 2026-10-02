import Foundation

/// Loads older pages of chat history for the chat and transcript models, keeping at most one
/// request in flight. The position in history is owned by the Core SDK.
final class OlderChatHistoryLoader {
    struct Environment {
        var fetchOlderChatHistory: CoreSdkClient.FetchOlderChatHistory
        var hasOlderChatHistory: CoreSdkClient.HasOlderChatHistory
        var log: CoreSdkClient.Logger
    }

    private let environment: Environment
    private(set) var isLoading = false

    init(environment: Environment) {
        self.environment = environment
    }

    var canLoad: Bool {
        environment.hasOlderChatHistory()
    }

    var canStartLoading: Bool {
        !isLoading && canLoad
    }

    /// Calls `completion` with the older page, oldest message first, or with `nil` on failure.
    /// Does nothing when a load is already in flight or nothing older exists.
    func load(_ completion: @escaping ([ChatMessage]?) -> Void) {
        guard canStartLoading else { return }
        isLoading = true
        environment.fetchOlderChatHistory { [weak self] result in
            self?.isLoading = false
            switch result {
            case let .success(messages):
                completion(messages)
            case let .failure(error):
                self?.environment.log.warning("Older chat history load failed: \(error)")
                completion(nil)
            }
        }
    }
}

extension OlderChatHistoryLoader.Environment {
    static func create(with environment: ChatViewModel.Environment) -> Self {
        .init(
            fetchOlderChatHistory: environment.fetchOlderChatHistory,
            hasOlderChatHistory: environment.hasOlderChatHistory,
            log: environment.log
        )
    }

    static func create(with environment: SecureConversations.TranscriptModel.Environment) -> Self {
        .init(
            fetchOlderChatHistory: environment.fetchOlderChatHistory,
            hasOlderChatHistory: environment.hasOlderChatHistory,
            log: environment.log
        )
    }
}
