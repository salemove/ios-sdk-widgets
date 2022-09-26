@testable import GliaWidgets
import XCTest
import WebKit

class WKNavigationPolicyProviderTests: XCTestCase {
    func test_policy() throws {
        typealias Result = (url: URL, policy: WKNavigationActionPolicy, shouldHandle: Bool)
        let policyProvider = WKNavigationPolicyProvider.customResponseCard
        let url = { try XCTUnwrap(URL(string: $0)) }
        let data: [Result] = try [
            (url("about://mock.mock"), .allow, false),
            (url("http://mock.mock"), .cancel, true),
            (url("https://mock.mock"), .cancel, true),
            (url("tel:12345678"), .cancel, true),
            (url("mailto:mock@mock.mock"), .cancel, true),
            (url("mock:mock"), .cancel, false)
        ]

        data.forEach { item in
            let result = policyProvider.policy(item.0)
            XCTAssertEqual(result.policy, item.policy)
            XCTAssertEqual(result.shouldHandleUrlSelection, item.shouldHandle)
        }
    }
}
