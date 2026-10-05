@testable import GliaWidgets
import XCTest
import WebKit

class WKNavigationPolicyProviderTests: XCTestCase {
    func test_policy() throws {
        typealias Request = WKNavigationPolicyProvider.Request
        struct Result {
            let request: Request
            let policy: WKNavigationActionPolicy
            let shouldHandle: Bool

            init(_ request: Request, _ policy: WKNavigationActionPolicy, _ shouldHandle: Bool) {
                self.request = request
                self.policy = policy
                self.shouldHandle = shouldHandle
            }
        }
        let policyProvider = WKNavigationPolicyProvider.customResponseCard
        let request = { (url: String, type: WKNavigationType, target: Request.Target) in
            Request(url: try XCTUnwrap(URL(string: url)), navigationType: type, target: target)
        }
        let data: [Result] = try [
            Result(request("about:blank", .other, .mainFrame), .allow, false),
            Result(request("https://mock.mock", .linkActivated, .mainFrame), .cancel, true),
            Result(request("https://mock.mock", .linkActivated, .newWindow), .cancel, true),
            Result(request("HTTPS://mock.mock", .linkActivated, .mainFrame), .cancel, true),
            Result(request("http://mock.mock", .linkActivated, .mainFrame), .cancel, true),
            Result(request("tel:12345678", .linkActivated, .mainFrame), .cancel, true),
            Result(request("mailto:mock@mock.mock", .linkActivated, .mainFrame), .cancel, true),
            Result(request("https://mock.mock", .other, .mainFrame), .cancel, false),
            Result(request("tel:12345678", .other, .mainFrame), .cancel, false),
            Result(request("https://mock.mock", .formSubmitted, .mainFrame), .cancel, false),
            Result(request("https://mock.mock", .other, .subframe), .cancel, false),
            Result(request("https://mock.mock", .linkActivated, .subframe), .cancel, false),
            Result(request("mock:mock", .linkActivated, .mainFrame), .cancel, false)
        ]

        data.forEach { item in
            let result = policyProvider.policy(item.request)
            XCTAssertEqual(result.policy, item.policy, "\(item.request)")
            XCTAssertEqual(result.shouldHandleUrlSelection, item.shouldHandle, "\(item.request)")
        }
    }
}
