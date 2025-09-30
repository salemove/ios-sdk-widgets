import Foundation
import GliaCoreSDK

public typealias PushNotificationsType = GliaCoreSDK.PushNotificationsType

public struct PushNotifications {
    let environment: Environment

    /// Notifies the push notifications system that the application has successfully registered for remote notifications.
    ///
    /// This method is usually called from the `UIApplicationDelegate`'s registration success callback.
    ///
    /// - Parameters:
    ///   - application: The application instance that registered for notifications.
    ///   - deviceToken: The device token received from APNs.
    ///
    public func applicationDidRegisterForRemoteNotificationsWithDeviceToken(
        application: UIApplication,
        deviceToken: Data
    ) {
        environment.openTelemetry.logger.logMethodUse(
            sdkType: .widgetsSdk,
            className: Self.self,
            methodName: "applicationDidRegisterForRemoteNotificationsWithDeviceToken",
            methodParams: ["application", "deviceToken"]
        )
        environment.coreSdk.pushNotifications.applicationDidRegisterForRemoteNotificationsWithDeviceToken(
            application,
            deviceToken
        )
    }

    /// Notifies the push notifications system that the application failed to register for remote notifications.
    ///
    /// This method is typically called from the `UIApplicationDelegate`'s failure callback.
    ///
    /// - Parameters:
    ///   - application: The application instance that attempted registration.
    ///   - error: The error encountered during the registration process.
    ///
    public func applicationDidFailToRegisterForRemoteNotificationsWithError(
        application: UIApplication,
        error: any Error
    ) {
        environment.openTelemetry.logger.logMethodUse(
            sdkType: .widgetsSdk,
            className: Self.self,
            methodName: "applicationDidFailToRegisterForRemoteNotificationsWithError",
            methodParams: ["application", "error"]
        )
        environment.coreSdk.pushNotifications.applicationDidFailToRegisterForRemoteNotificationsWithError(
            application,
            error
        )
    }

    /// Forwards the notification delivery event to the underlying SDK when a notification is about to be presented.
    ///
    /// This method should be called from `UNUserNotificationCenterDelegate`'s
    /// `userNotificationCenter(_:willPresent:withCompletionHandler:)` method.
    ///
    /// - Parameters:
    ///   - center: The `UNUserNotificationCenter` instance handling the notification.
    ///   - willPresentNotificationCenter: The `UNNotification` to be presented.
    ///   - completionHandler: A closure that takes the presentation options for the notification.
    ///
    public func userNotificationCenterWillPresent(
        center: UNUserNotificationCenter,
        willPresent: UNNotification,
        completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        environment.openTelemetry.logger.logMethodUse(
            sdkType: .widgetsSdk,
            className: Self.self,
            methodName: "userNotificationCenterWillPresent",
            methodParams: ["center", "willPresent", "completionHandler"]
        )
        environment.coreSdk.pushNotifications.userNotificationCenterWillPresent(
            center,
            willPresent,
            completionHandler
        )
    }

    /// Forwards the user's response for a delivered notification to the underlying SDK.
    ///
    /// This method should be invoked from `UNUserNotificationCenterDelegate`'s
    /// `userNotificationCenter(_:didReceive:withCompletionHandler:)` method.
    ///
    /// - Parameters:
    ///   - center: The `UNUserNotificationCenter` instance that handled the response.
    ///   - didReceiveResponseCenter: The `UNNotificationResponse` received from the user.
    ///   - completionHandler: A closure executed once the response has been handled.
    ///
    public func userNotificationCenterDidReceiveResponse(
        center: UNUserNotificationCenter,
        didReceive: UNNotificationResponse,
        completionHandler: @escaping () -> Void
    ) {
        environment.openTelemetry.logger.logMethodUse(
            sdkType: .widgetsSdk,
            className: Self.self,
            methodName: "userNotificationCenterDidReceiveResponse",
            methodParams: ["center", "didReceive", "completionHandler"]
        )
        environment.coreSdk.pushNotifications.userNotificationCenterDidReceiveResponse(
            center,
            didReceive,
            completionHandler
        )
    }

    /// Sets the current push action handler that the SDK uses to forward notification actions.
    ///
    /// This handler is executed in response to user interactions with notifications (via
    /// `UNNotificationResponse.actionIdentifier`).
    ///
    /// - Parameter handler: An optional `PushActionBlock` closure used as a callback for push actions.
    ///
    public func setPushHandler(_ handler: GliaCoreSDK.PushActionBlock?) {
        environment.openTelemetry.logger.logMethodUse(
            sdkType: .widgetsSdk,
            className: Self.self,
            methodName: "setPushHandler",
            methodParams: ["handler"]
        )
        environment.coreSdk.pushNotifications.setPushHandler(handler)
    }

    /// Subscribe to specific push notifications type.
    ///
    /// - Parameters:
    ///   - types: array of PushnotificationType
    ///
    public func subscribeTo(_ types: [PushNotificationsType]) {
        environment.openTelemetry.logger.logMethodUse(
            sdkType: .widgetsSdk,
            className: Self.self,
            methodName: "subscribeTo",
            methodParams: ["types"]
        )
        environment.coreSdk.pushNotifications.subscribeTo(types)
    }
}
