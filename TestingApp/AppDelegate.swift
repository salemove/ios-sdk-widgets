import UIKit
import SalemoveSDK

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    var salemoveDelegate = SalemoveAppDelegate()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        let viewController = ViewController()
        let navigationController = UINavigationController(rootViewController: viewController)
        let window = UIWindow()
        self.window = window
        window.rootViewController = navigationController
        window.makeKeyAndVisible()
        salemoveDelegate.application(application, didFinishLaunchingWithOptions: launchOptions)
        return true
    }

    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        salemoveDelegate.application(application, didRegisterForRemoteNotificationsWithDeviceToken: deviceToken)
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        salemoveDelegate.applicationDidBecomeActive(application)
    }
}
