import UIKit
import SalemoveSDK

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    var salemoveDelegate = SalemoveAppDelegate()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        salemoveDelegate.application(
            application,
            didFinishLaunchingWithOptions: launchOptions
        )
        return true
    }

    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        print("Registered for remote notifications")
        Salemove.sharedInstance.pushNotifications.application(
            application,
            didRegisterForRemoteNotificationsWithDeviceToken: deviceToken
        )
    }

    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Failed to register for remote notifications. Error: \(error.localizedDescription)")
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        salemoveDelegate.applicationDidBecomeActive(application)
    }
}
