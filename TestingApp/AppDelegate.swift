import UIKit
import SalemoveSDK

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(
        _ app: UIApplication,
        open url: URL,
        options: [UIApplication.OpenURLOptionsKey : Any] = [:]
    ) -> Bool {

        guard
            let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
            let queryItems = components.queryItems
        else {
            debugPrint("URL is not valid. url='\(url.absoluteString)'.")
            return false
        }

        guard let root = window?.rootViewController as? ViewController else {
            return false
        }

        if components.host == "configure" {
            root.updateConfiguration(with: queryItems)
        }
        return true
    }

    func application(
        _ application: UIApplication,
        didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
    ) {
        debugPrint("✅ Registered for remote notifications. Token='\(deviceToken.map { String(format: "%02.2hhx", $0) }.joined())'.")
        GliaCore.sharedInstance.pushNotifications.application(
            application,
            didRegisterForRemoteNotificationsWithDeviceToken: deviceToken
        )
    }

    func application(
        _ application: UIApplication,
        didFailToRegisterForRemoteNotificationsWithError error: Error
    ) {
        print("💥 Failed to register for remote notifications. Error: \(error.localizedDescription)")
    }
}
