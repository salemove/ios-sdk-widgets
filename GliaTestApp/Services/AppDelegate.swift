import UIKit
import GliaWidgets
import GliaCoreSDK

final class AppDelegate: UIResponder, UIApplicationDelegate {
    private let gliaCoreAppDelegate = GliaCoreAppDelegate()

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        gliaCoreAppDelegate.application(application, didFinishLaunchingWithOptions: launchOptions)
        debugPrint("🚀 GliaTestApp AppDelegate didFinishLaunching")
        return true
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        gliaCoreAppDelegate.applicationDidBecomeActive(application)
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
