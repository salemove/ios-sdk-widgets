import UIKit
import SalemoveSDK
import GliaWidgets

private let logger = Logger.live(name: "AppDelegate")

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    var salemoveDelegate = SalemoveAppDelegate()

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        salemoveDelegate.application(
            application,
            didFinishLaunchingWithOptions: launchOptions
        )
        return true
    }

    func application(
        _ application: UIApplication,
        didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
    ) {
        logger.debug("Application has been registered for remote notifications.")

        Salemove.sharedInstance.pushNotifications.application(
            application,
            didRegisterForRemoteNotificationsWithDeviceToken: deviceToken
        )
    }

    func application(
        _ application: UIApplication,
        didFailToRegisterForRemoteNotificationsWithError error: Error
    ) {
        logger.warning("Failed to register for remote notifications. Error: \(error.localizedDescription)")
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        salemoveDelegate.applicationDidBecomeActive(application)
    }
}
