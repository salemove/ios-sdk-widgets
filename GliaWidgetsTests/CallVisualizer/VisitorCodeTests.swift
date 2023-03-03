@testable import GliaWidgets
import XCTest
import SalemoveSDK

class VisitorCodeTests: XCTestCase {
    func test_vc_deinit() {
        weak var weakViewController: CallVisualizer.VisitorCodeViewController?
        autoreleasepool {
            let viewController = CallVisualizer.VisitorCodeViewController(
                props: .init(visitorCodeViewProps: .init())
            )
            weakViewController = viewController
        }
        XCTAssertNil(weakViewController, "VisitorCodeViewController not deinitilized")
    }

    func test_visitorCode_displayed() {
        let visitorCode = "12345"
        let view = CallVisualizer.VisitorCodeView()
        view.props = .init(viewState: .success(visitorCode: visitorCode))
        XCTAssertEqual(visitorCode, view.renderedVisitorCode, "Visitor Code not displayed properly")
        XCTAssertEqual(view.titleLabel.text, L10n.CallVisualizer.VisitorCode.Title.standard)
    }

    func test_error_displayed() {
        let view = CallVisualizer.VisitorCodeView()
        view.props = .init(viewState: .error(refreshTap: .nop))
        XCTAssertTrue(view.stackView.arrangedSubviews.contains(view.refreshButton))
        XCTAssertEqual(view.titleLabel.text, L10n.CallVisualizer.VisitorCode.Title.error)
    }

    func test_spinner_displayed() {
        let view = CallVisualizer.VisitorCodeView()
        view.props = .init(viewState: .loading)
        XCTAssertTrue(view.stackView.arrangedSubviews.contains(view.spinnerView))
        XCTAssertEqual(view.titleLabel.text, L10n.CallVisualizer.VisitorCode.Title.standard)
    }

    func test_closeButton_visibility() {
        let view = CallVisualizer.VisitorCodeView()

        view.props = .init(viewType: .embedded)
        XCTAssertTrue(view.closeButton.isHidden)

        view.props = .init(viewType: .alert(closeButtonTap: .nop))
        XCTAssertFalse(view.closeButton.isHidden)
    }

    func test_if_timer_is_scheduled() {
        let viewController = UIViewController()
        let viewModel = CallVisualizer.VisitorCodeViewModel.mock(
            presentation: .alert(viewController)
        )
        viewModel.visitorCodeExpiresAt = .mock
        viewModel.viewState = .success(visitorCode: "123456")
        viewModel.scheduleVisitorCodeRefresh()
        XCTAssertTrue(viewModel.timer != nil)
    }

    func test_poweredBy_visibility() {
        let view = CallVisualizer.VisitorCodeView()
        view.props = .init(isPoweredByShown: false)

        XCTAssertTrue(view.poweredBy.alpha == 0)
    }
}
