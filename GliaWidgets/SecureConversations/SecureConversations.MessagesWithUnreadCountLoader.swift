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

        func loadMessagesWithUnreadCount() async throws -> MessagesWithUnreadCount {
            async let unreadTask: Int = unreadCountWithTimeout()
            let messages = try await environment.fetchChatHistory()
            let unreadCount = (try? await unreadTask) ?? 0

            return MessagesWithUnreadCount(messages: messages, unreadCount: unreadCount)
        }

        private func unreadCountWithTimeout() async throws -> Int {
            try await Self.withTimeout(seconds: Self.unreadCountFallbackTimeoutSeconds) {
                try await environment.getSecureUnreadMessageCount()
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
