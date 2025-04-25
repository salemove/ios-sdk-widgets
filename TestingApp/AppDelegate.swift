import UIKit
import GliaWidgets

@main
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    var window: UIWindow?
    lazy var deeplinkService: DeeplinksService = {
        let deepLinksHandlers: [DeeplinksService.Host: DeeplinkHandler.Type] = [
            .configure: ConfigurationDeeplinkHandler.self,
            .widgets: SettingsDeeplinkHandler.self
        ]
        return .init(window: window, handlers: deepLinksHandlers)
    }()
    
    
    func applicationDidFinishLaunching(_ application: UIApplication) {
        handleProcessInfo()
        handleSetAnimationsEnabled()
    }
    
//    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
//        UNUserNotificationCenter.current().delegate = self
//        return true
//    }
    
    func application(
        _ app: UIApplication,
        open url: URL,
        options: [UIApplication.OpenURLOptionsKey: Any] = [:]
    ) -> Bool {
        deeplinkService.openUrl(url, withOptions: options)
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
//    func topViewController() -> UIViewController? {
//        
//        if var topController = UIApplication.shared.windows.first(where: { $0.isKeyWindow })?.rootViewController {
//            while let presentedViewController = topController.presentedViewController {
//                topController = presentedViewController
//            }
//            return topController
//        }
//        return nil
//        
//    }
//    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
//        
//        let alert = UIAlertController(title: "Wohooo", message: "", preferredStyle: .alert)
//        topViewController().present(alert, animated: true)
        Glia.sharedInstance.pushNotifications.userNotificationCenterDidReceiveResponse(center: center, didReceive: response, completionHandler: completionHandler)
    }

    func application(
        _ application: UIApplication,
        didFailToRegisterForRemoteNotificationsWithError error: Error
    ) {
        debugPrint("💥 Failed to register for remote notifications. Error: \(error.localizedDescription)")
    }

    private  func handleProcessInfo() {
        guard let configurationUrl = ProcessInfo.processInfo.environment["CONFIGURATION_URL"] else {
            return
        }

        debugPrint(configurationUrl)

        guard let url = URL(string: configurationUrl) else { return }
        deeplinkService.openUrl(url, withOptions: [:])
    }

    private func handleSetAnimationsEnabled() {
        let env = ProcessInfo.processInfo.environment
        if env["SET_ANIMATION_ENABLED"] == "false" {
            UIView.setAnimationsEnabled(false)
        }
    }
}
