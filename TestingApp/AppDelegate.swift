import UIKit
import GliaCoreSDK

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
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
        GliaCore.sharedInstance.pushNotifications.application(
            application,
            didRegisterForRemoteNotificationsWithDeviceToken: deviceToken
        )
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
