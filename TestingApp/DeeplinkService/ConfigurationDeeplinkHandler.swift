import UIKit

struct ConfigurationDeeplinkHandler: DeeplinkHandler {
    private let window: UIWindow?

    init(window: UIWindow?) {
        self.window = window
    }

    func handleDeeplink(
        with path: String?,
        queryItems: [URLQueryItem]?
    ) -> Bool {
        guard let queryItems,
              let root = window?.rootViewController as? ViewController else {
            return false
        }
        root.updateConfiguration(with: queryItems)
        return true
    }
}
