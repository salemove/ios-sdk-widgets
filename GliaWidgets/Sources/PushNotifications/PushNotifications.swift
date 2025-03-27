import Foundation
import GliaCoreSDK

public struct PushNotifications {
    let environment: Environment

    /// Application did register for remote notifications with device token
    public func applicationDidRegisterForRemoteNotificationsWithDeviceToken(
        application: UIApplication,
        deviceToken: Data
    ) {
        environment.coreSdk.pushNotifications.applicationDidRegisterForRemoteNotificationsWithDeviceToken(
            application,
            deviceToken
        )
    }

    /// Set the current handler that the SDK is forwarding the
    /// UNNotificationResponse.actionIdentifier to.
    public func setPushHandler(_ handler: GliaCoreSDK.PushActionBlock?) {
        environment.coreSdk.pushNotifications.setPushHandler(handler)
    }

    /// The current handler that the SDK is forwarding the
    /// UNNotificationResponse.actionIdentifier to.
    public func pushHandler() -> GliaCoreSDK.PushActionBlock? {
        environment.coreSdk.pushNotifications.pushHandler()
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
