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
        Salemove.sharedInstance.pushNotifications.enable(true)
        return true
    }

    func application(
        _ app: UIApplication,
        open url: URL,
        options: [UIApplication.OpenURLOptionsKey : Any] = [:]
    ) -> Bool {

        guard
            let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
            let queryItems = components.queryItems,
            components.host == "configure"
        else {
            debugPrint("URL is not supported. url='\(url.absoluteString)'.")
            return false
        }

        guard let root = (window?.rootViewController as? ViewController) else {
            return false
        }

        root.updateConf(with: queryItems)
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
