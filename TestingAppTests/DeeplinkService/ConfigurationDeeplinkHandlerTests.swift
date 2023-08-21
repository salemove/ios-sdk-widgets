@testable import TestingApp
import XCTest

final class ConfigurationDeeplinkHandlerTests: XCTestCase {
    func test_handleDeeplink() throws {
        let window = UIWindow()
        window.rootViewController = ViewController()
        let handler = ConfigurationDeeplinkHandler(window: window)
        let urlString = """
        glia://configure?site_id=&mockapi_key_secret=mock&api_key_id=mock&queue_id=mock&env=us&visitor_context_asset_id=null
        """
        let url = try XCTUnwrap(URL(string: urlString))
        let components = try XCTUnwrap(URLComponents(url: url, resolvingAgainstBaseURL: false))
        let result = handler.handleDeeplink(
            with: url.lastPathComponent,
            queryItems: components.queryItems
        )
        XCTAssertTrue(result)
    }
}
