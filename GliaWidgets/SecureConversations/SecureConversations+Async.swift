import Foundation

public extension SecureConversations {
    /// Gets the count of unread messages sent through secure conversations.
    ///
    /// Async equivalent of `getUnreadMessageCount(_:)`.
    func getUnreadMessageCount() async throws -> Int {
        try await withCheckedThrowingContinuation { continuation in
            getUnreadMessageCount { result in
                continuation.resume(with: result)
            }
        }
    }

    /// Observes the count of unread messages sent through secure conversations.
    ///
    /// Async sequence equivalent of `subscribeSecureUnreadMessageCount(_:)`.
    func subscribeSecureUnreadMessageCount() -> AsyncThrowingStream<Int?, Error> {
        environment.openTelemetry.logger.logMethodUse(
            sdkType: .widgetsSdk,
            className: Self.self,
            methodName: "subscribeSecureUnreadMessageCount",
            methodParams: []
        )
        return environment.coreSdk.secureConversations.subscribeForUnreadMessageCount()
    }
}
