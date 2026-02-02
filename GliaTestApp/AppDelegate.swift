import UIKit
import GliaWidgets

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
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
