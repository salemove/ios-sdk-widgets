import UIKit
import GliaCoreSDK

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func applicationDidFinishLaunching(_ application: UIApplication) {
        handleProcessInfo()
        handleSetAnimationsEnabled()
    }

    func application(
        _ app: UIApplication,
        open url: URL,
        options: [UIApplication.OpenURLOptionsKey: Any] = [:]
    ) -> Bool {
        handleConfigurationUrl(url: url)
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
        debugPrint("💥 Failed to register for remote notifications. Error: \(error.localizedDescription)")
    }

    private  func handleProcessInfo() {
        guard let configurationUrl = ProcessInfo.processInfo.environment["CONFIGURATION_URL"] else {
            return
        }

        debugPrint(configurationUrl)

        guard let url = URL(string: configurationUrl) else { return }
        handleConfigurationUrl(url: url)
    }

    @discardableResult
    private func handleConfigurationUrl(url: URL) -> Bool {
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

    private func handleSetAnimationsEnabled() {
        let env = ProcessInfo.processInfo.environment
        if env["SET_ANIMATION_ENABLED"] == "false" {
            UIView.setAnimationsEnabled(false)
        }
    }
}
