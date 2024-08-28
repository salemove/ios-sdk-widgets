@testable import TestingApp
import XCTest

final class SettingsDeeplinkHandlerTests: XCTestCase {
    func test_handleDeeplink() throws {
        let window = UIWindow()
        let bundle = Bundle(for: ViewController.self)
        let storyboard = UIStoryboard(name: "Main", bundle: bundle)
        window.rootViewController = storyboard.instantiateViewController(withIdentifier: "ViewController")
        let handler = SettingsDeeplinkHandler(window: window)
        let url = try XCTUnwrap(URL(string: "glia://widgets/settings"))
        let result = handler.handleDeeplink(
            with: url.lastPathComponent,
            queryItems: []
        )
        XCTAssertTrue(result)
    }
}
