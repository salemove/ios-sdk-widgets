import UIKit
import GliaWidgets

final class AppDelegate: UIResponder, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        debugPrint("🚀 GliaTestApp AppDelegate didFinishLaunching")
        return true
    }

    func application(
        _ app: UIApplication,
        open url: URL,
        options: [UIApplication.OpenURLOptionsKey: Any] = [:]
    ) -> Bool {
        NotificationCenter.default.post(name: .openDeepLinkURL, object: url)
        return true
    }

    func application(
        _ application: UIApplication,
        didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
    ) {
        debugPrint("✅ Registered for remote notifications. Token='\(deviceToken.map { String(format: "%02.2hhx", $0) }.joined())'.")
        Glia.sharedInstance.pushNotifications.applicationDidRegisterForRemoteNotificationsWithDeviceToken(
            application: application,
            deviceToken: deviceToken
        )
    }

    func application(
        _ application: UIApplication,
        didFailToRegisterForRemoteNotificationsWithError error: Error
    ) {
        debugPrint("💥 Failed to register for remote notifications. Error: \(error.localizedDescription)")
    }
}
