import UIKit
import GliaWidgets

protocol DeeplinkHandler {
    init(context: DeeplinkContext)
    @MainActor
    func handleDeeplink(with path: String?, queryItems: [URLQueryItem]?) -> Bool
}

struct DeeplinkContext {
    let appState: AppState
    let showSettings: @MainActor () -> Void
}

final class AppDelegate: UIResponder, UIApplicationDelegate {
    func application(
        _ app: UIApplication,
        open url: URL,
        options: [UIApplication.OpenURLOptionsKey : Any] = [:]
    ) -> Bool {
        NotificationCenter.default.post(name: .openDeepLinkURL, object: url)
        return true
    }

    func application(
        _ application: UIApplication,
        didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
    ) {
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
