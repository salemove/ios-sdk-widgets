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
            let stateQueue = DispatchQueue(label: "MessagesWithUnreadCountLoader.state")
            var didCallback = false
            var messagesResult: Result<[ChatMessage], Error>?
            var unreadResult: Result<Int, Error>?

            func finishIfReady() {
                stateQueue.async {
                    guard !didCallback,
                          let m = messagesResult,
                          let u = unreadResult
                    else { return }
                    didCallback = true
                    let combined = Self.messageWithUnreadCountResult(
                        messageResult: m,
                        unreadCountResult: u
                    )
                    DispatchQueue.main.async {
                        callback(combined)
                    }
                }
            }

            Task {
                do {
                    let count = try await Self.withTimeout(seconds: Self.unreadCountFallbackTimeoutSeconds) {
                        try await environment.getSecureUnreadMessageCount()
                    }
                    stateQueue.async {
                        unreadResult = .success(count)
                        finishIfReady()
                    }
                } catch {
                    stateQueue.async {
                        unreadResult = .failure(error)
                        finishIfReady()
                    }
                }
            }

            environment.fetchChatHistory { (result: Result<[ChatMessage], CoreSdkClient.SalemoveError>) in
                let mapped: Result<[ChatMessage], Error> = result.mapError { $0 as Error }
                stateQueue.async {
                    messagesResult = mapped
                    finishIfReady()
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

        private static func withTimeout<T>(
            seconds: TimeInterval,
            operation: @escaping () async throws -> T
        ) async throws -> T {
            try await withThrowingTaskGroup(of: T.self) { group in
                group.addTask { try await operation() }
                group.addTask {
                    try await Task.sleep(nanoseconds: UInt64(seconds * 1_000_000_000))
                    throw TimeoutError()
                }

                guard let first = try await group.next() else {
                    throw TimeoutError()
                }

                group.cancelAll()
                return first
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
