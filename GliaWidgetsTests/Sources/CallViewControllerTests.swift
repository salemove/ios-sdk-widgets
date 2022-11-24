@testable import GliaWidgets
import SalemoveSDK
import XCTest

class CallViewControllerTests: XCTestCase {
    func test_call_deinit() {
        weak var weakViewController: CallViewController?
        autoreleasepool {
            let viewController: CallViewController? = CallViewController(
                viewModel: CallViewModel.mock(environment: CallViewModel.Environment.mock),
                viewFactory: ViewFactory.mock()
            )
            weakViewController = viewController
        }
        XCTAssertNil(weakViewController, "CallViewController not deinitilized")
    }
}
