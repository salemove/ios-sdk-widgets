import UIKit

struct SettingsDeeplinkHandler: DeeplinkHandler {
    enum Path: String {
        case settings
    }

    private let window: UIWindow?
    init(window: UIWindow?) {
        self.window = window
    }

    func handleDeeplink(
        with path: String?,
        queryItems: [URLQueryItem]?
    ) -> Bool {
        guard path == Path.settings.rawValue,
              let root = window?.rootViewController as? ViewController else {
            return false
        }
        root.presentSettings()
        return true
    }
}
