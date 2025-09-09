import Foundation
import GliaCoreSDK

/// Namespace for all secure conversations functionality
public struct SecureConversations {
    let environment: Environment

    /// Gets the count of unread messages sent through secure conversations.
    ///
    /// This count will increase if an operator sends a message and the visitor hasn't marked them as read yet.
    ///
    /// - Parameter completion: A callback that will return a `Result` with the number of unread
    /// secure conversation messages on success, or `Swift.Error` on failure.
    public func getUnreadMessageCount(_ callback: @escaping (Result<Int, Error>) -> Void) {
        environment.openTelemetry.logger.logMethodUse(
            sdkType: .widgetsSdk,
            className: Self.self,
            methodName: "getUnreadMessageCount",
            methodParams: "callback"
        )
        environment.coreSdk.secureConversations.getUnreadMessageCount(callback)
    }

    /// Observes the count of unread messages sent through secure conversations.
    ///
    /// This count will increase if an operator sends a message and the visitor hasn't marked
    /// them as read yet
    ///
    /// - Parameter completion: A callback that will call a `Result` with the number of unread
    /// secure conversation messages on success every time `unreadMessageCount` changes, or `Swift.Error` on failure.
    ///
    /// - returns:
    /// A unique callback ID or `nil` if callback was not registered due to error.
    /// This callback ID could be used to usubscribe from Secure Conversation unread messages count updates.
    public func subscribeSecureUnreadMessageCount(_ completion: @escaping (Result<Int?, Error>) -> Void) -> String? {
        environment.openTelemetry.logger.logMethodUse(
            sdkType: .widgetsSdk,
            className: Self.self,
            methodName: "subscribeSecureUnreadMessageCount)",
            methodParams: "completion"
        )
        return environment.coreSdk.secureConversations.subscribeForUnreadMessageCount(completion)
    }

    /// Remove subscription for 'subscribeToUnreadMessageCount' methods updates.
    /// 
    /// - Parameter subscriptionToken: Subscription token produced by `subscribeToUnreadMessageCount` method.
    public func unsubscribeSecureUnreadMessageCount(_ subscriptionToken: String) {
        environment.openTelemetry.logger.logMethodUse(
            sdkType: .widgetsSdk,
            className: Self.self,
            methodName: "unsubscribeSecureUnreadMessageCount(_:)",
            methodParams: "subscriptionToken"
        )
        return environment.coreSdk.secureConversations.unsubscribeFromUnreadMessageCount(subscriptionToken)
    }
}

extension SecureConversations {
    struct Environment {
        let coreSdk: CoreSdkClient
        @Dependency(\.widgets.openTelemetry) var openTelemetry: OpenTelemetry
    }
}

extension SecureConversations.Environment {
    static func create(with environment: Glia.Environment) -> Self {
        .init(coreSdk: environment.coreSdk)
    }
}
