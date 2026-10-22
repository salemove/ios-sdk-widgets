import UIKit
import XCTest
@testable import GliaWidgets

func fail(_ failingFuncName: String, file: StaticString = #filePath, line: UInt = #line) {
    XCTFail("\(failingFuncName) - A failing environment function is invoked.", file: file, line: line)
}

/// Records presented view controllers instead of presenting them, so coordinator tests can
/// assert on presentation without a window.
final class RecordingNavigationController: NavigationController {
    private(set) var presentedViewControllers: [UIViewController] = []

    override func present(
        _ viewControllerToPresent: UIViewController,
        animated flag: Bool,
        completion: (() -> Void)? = nil
    ) {
        presentedViewControllers.append(viewControllerToPresent)
        completion?()
    }
}
