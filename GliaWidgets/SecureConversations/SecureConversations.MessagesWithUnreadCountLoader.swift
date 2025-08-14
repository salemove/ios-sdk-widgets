import Foundation

extension SecureConversations {
    struct MessagesWithUnreadCount {
        var messages: [ChatMessage]
        var unreadCount: Int
    }

    /// Due to async nature of requests, we need to make sure
    /// that `unread message count` and `transcript messages`
    /// are delivered at once. This entity makes it possible.
    struct MessagesWithUnreadCountLoader {
        static let unreadCountFallbackTimeoutSeconds: TimeInterval = 3.0

        struct TimeoutError: Error {}

        var environment: Environment

        func loadMessagesWithUnreadCount(callback: @escaping (Result<MessagesWithUnreadCount, Error>) -> Void) {
            Task {
                do {
                    let messages = try await environment.fetchChatHistory()
                    getSecureUnreadMessageCountWithTimeout(timeout: Self.unreadCountFallbackTimeoutSeconds) { count in
                        callback(.success(MessagesWithUnreadCount(messages: messages, unreadCount: count)))
                    }
                } catch {
                    callback(.failure(error))
                }
            }
        }

        static func messageWithUnreadCountResult(
            messageResult: Result<[ChatMessage], Error>,
            unreadCountResult: Result<Int, Error>
        ) -> Result<MessagesWithUnreadCount, Error> {
                // Without messages unread count does not make much sense,
                // that is why we prefer to report error for messages in case
                // of failure for both requests. Same for success - ignore
                // unreadCount failure in case of successful loading of messages.
                switch (messageResult, unreadCountResult) {
                case let (.success(messages), .success(unreadCount)):
                    return .success(MessagesWithUnreadCount(messages: messages, unreadCount: unreadCount))
                case let (.success(messages), .failure):
                    return .success(MessagesWithUnreadCount(messages: messages, unreadCount: .zero))
                case let (.failure(error), .failure), let (.failure(error), .success):
                    return .failure(error)
                }
            }

        func getSecureUnreadMessageCountWithTimeout(
            timeout: TimeInterval,
            completion: @escaping (Int) -> Void
        ) {
            var didFinish = false

            environment.getSecureUnreadMessageCount { result in
                guard !didFinish else { return }
                didFinish = true

                switch result {
                case .success(let count):
                    completion(count)
                case .failure:
                    completion(0)
                }
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + timeout) {
                if !didFinish {
                    didFinish = true
                    completion(0)
                }
            }
        }
    }
}

extension SecureConversations.MessagesWithUnreadCount {
    static let empty = SecureConversations.MessagesWithUnreadCount(
        messages: [],
        unreadCount: 0
    )
}
