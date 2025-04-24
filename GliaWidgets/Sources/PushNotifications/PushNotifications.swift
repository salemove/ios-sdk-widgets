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
        environment.coreSdk.pushNotifications.applicationDidFailToRegisterForRemoteNotificationsWithError(
            application,
            error
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
        environment.coreSdk.pushNotifications.setPushHandler(handler)
    }

    /// Subscribe to specific push notifications type.
    ///
    /// - Parameters:
    ///   - types: array of PushnotificationType
    ///
    public func subscribeTo(_ types: [PushNotificationsType]) {
        environment.coreSdk.pushNotifications.subscribeTo(types)
    }
}

extension PushNotifications {
    struct Environment {
        let coreSdk: CoreSdkClient
    }
}

extension PushNotifications.Environment {
    static func create(with environment: Glia.Environment) -> Self {
        .init(coreSdk: environment.coreSdk)
    }
}
