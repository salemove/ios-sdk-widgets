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
            typealias ReactiveSwift = CoreSdkClient.ReactiveSwift
            let unreadCountTimeoutProducer = ReactiveSwift.SignalProducer<Void, Never>(value: ())
            let unreadCountRequestSource = ReactiveSwift.Signal<Result<Int, Error>, Never>.pipe()
            let unreadCountTimeoutSource = ReactiveSwift.Signal<Result<Int, Error>, Never>.pipe()
            // In case if `unreadCount` will never be delivered,
            // (for example if sockets are disconnected, because
            // `unreadCount` is based on sockets)
            // we will still receive callback by timeout.
            let unreadCountRequestWithTimeoutSource = ReactiveSwift.Signal.merge(
                unreadCountRequestSource.output,
                unreadCountTimeoutSource.output
            ).take(first: 1)

            let messagesSource = ReactiveSwift.Signal<Result<[ChatMessage], CoreSdkClient.SalemoveError>, Never>.pipe()

            let combined = ReactiveSwift.Signal.zip(
                messagesSource.output,
                unreadCountRequestWithTimeoutSource
            )

            unreadCountTimeoutProducer
                .delay(Self.unreadCountFallbackTimeoutSeconds, on: environment.scheduler)
                .startWithCompleted {
                    unreadCountTimeoutSource.input.send(value: .failure(TimeoutError()))
                }

            combined
                .observe(on: environment.scheduler)
                .observeValues { messageResult, unreadCountResult in
                    callback(
                        Self.messageWithUnreadCountResult(
                            messageResult: messageResult.mapError { $0 as Error },
                            unreadCountResult: unreadCountResult
                        )
                    )
                }

            environment.getSecureUnreadMessageCount(unreadCountRequestSource.input.send(value:))
            environment.fetchChatHistory(messagesSource.input.send(value:))
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
    }
}

extension SecureConversations.MessagesWithUnreadCount {
    static let empty = SecureConversations.MessagesWithUnreadCount(
        messages: [],
        unreadCount: 0
    )
}

extension SecureConversations.MessagesWithUnreadCountLoader {
    struct Environment {
        var getSecureUnreadMessageCount: CoreSdkClient.GetSecureUnreadMessageCount
        var fetchChatHistory: CoreSdkClient.FetchChatHistory
        var scheduler: CoreSdkClient.ReactiveSwift.DateScheduler
    }
}
