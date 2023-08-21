@testable import TestingApp
import UIKit

final class DeeplinkHandlerMock: DeeplinkHandler {
    let window: UIWindow?

    init(window: UIWindow?) {
        self.window = window
    }

    func handleDeeplink(
        with path: String?,
        queryItems: [URLQueryItem]?
    ) -> Bool {
        return true
    }
}
