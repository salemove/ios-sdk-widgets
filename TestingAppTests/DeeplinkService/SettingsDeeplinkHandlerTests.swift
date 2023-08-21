@testable import TestingApp
import XCTest

final class SettingsDeeplinkHandlerTests: XCTestCase {
    func test_handleDeeplink() throws {
        let window = UIWindow()
        window.rootViewController = ViewController()
        let handler = SettingsDeeplinkHandler(window: window)
        let url = try XCTUnwrap(URL(string: "glia://widgets/settings"))
        let result = handler.handleDeeplink(
            with: url.lastPathComponent,
            queryItems: []
        )
        XCTAssertTrue(result)
    }
}
