import SalemoveSDK

extension CoreSdkClient {
    static let live: Self = {
        .init(
            pushNotifications: .live,
            createAppDelegate: Self.AppDelegate.live
        )
    }()
}

extension CoreSdkClient.PushNotifications {
    static let live = Self(
        applicationDidRegisterForRemoteNotificationsWithDeviceToken:
            Salemove.sharedInstance.pushNotifications.application(_:didRegisterForRemoteNotificationsWithDeviceToken:)
    )
}

extension CoreSdkClient.AppDelegate {
    static func live() -> Self {
        let salemoveDelegate = SalemoveAppDelegate()
        return .init(
            applicationDidFinishLaunchingWithOptions: salemoveDelegate.application(_:didFinishLaunchingWithOptions:),
            applicationDidBecomeActive: salemoveDelegate.applicationDidBecomeActive
        )
    }
}
