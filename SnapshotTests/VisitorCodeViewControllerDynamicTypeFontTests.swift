@testable import GliaWidgets
import SnapshotTesting
import XCTest

// swiftlint:disable type_name
final class VisitorCodeViewControllerDynamicTypeFontTests: SnapshotTestCase {
    func testVisitorCodeAlertWhenLoading() {
        let props: CallVisualizer.VisitorCodeViewController.Props = .init(
            visitorCodeViewProps: .init(
                viewType: .alert(closeButtonTap: .nop),
                viewState: .loading
            )
        )
        let visitorCodeViewController = CallVisualizer.VisitorCodeViewController(props: props)
        visitorCodeViewController.view.frame = UIScreen.main.bounds

        assertSnapshot(
            matching: visitorCodeViewController,
            as: .extra3LargeFontStrategy,
            named: nameForDevice()
        )
    }

    func testVisitorCodeAlertWhenError() {
        let props: CallVisualizer.VisitorCodeViewController.Props = .init(
            visitorCodeViewProps: .init(
                viewType: .alert(closeButtonTap: .nop),
                viewState: .error(refreshTap: .nop)
            )
        )
        let visitorCodeViewController = CallVisualizer.VisitorCodeViewController(props: props)
        visitorCodeViewController.view.frame = UIScreen.main.bounds

        assertSnapshot(
            matching: visitorCodeViewController,
            as: .extra3LargeFontStrategy,
            named: nameForDevice()
        )
    }

    func testVisitorCodeAlertWhenSuccess() {
        let props: CallVisualizer.VisitorCodeViewController.Props = .init(
            visitorCodeViewProps: .init(
                viewType: .alert(closeButtonTap: .nop),
                viewState: .success(visitorCode: "12345")
            )
        )
        let visitorCodeViewController = CallVisualizer.VisitorCodeViewController(props: props)
        visitorCodeViewController.view.frame = UIScreen.main.bounds

        assertSnapshot(
            matching: visitorCodeViewController,
            as: .extra3LargeFontStrategy,
            named: nameForDevice()
        )
    }

    func testVisitorCodeEmbeddedWhenLoading() {
        let props: CallVisualizer.VisitorCodeViewController.Props = .init(
            visitorCodeViewProps: .init(
                viewType: .embedded,
                viewState: .loading
            )
        )
        let visitorCodeViewController = CallVisualizer.VisitorCodeViewController(props: props)
        visitorCodeViewController.view.frame = UIScreen.main.bounds

        assertSnapshot(
            matching: visitorCodeViewController,
            as: .extra3LargeFontStrategy,
            named: nameForDevice()
        )
    }

    func testVisitorCodeEmbeddedWhenError() {
        let props: CallVisualizer.VisitorCodeViewController.Props = .init(
            visitorCodeViewProps: .init(
                viewType: .embedded,
                viewState: .error(refreshTap: .nop)
            )
        )
        let visitorCodeViewController = CallVisualizer.VisitorCodeViewController(props: props)
        visitorCodeViewController.view.frame = UIScreen.main.bounds

        assertSnapshot(
            matching: visitorCodeViewController,
            as: .extra3LargeFontStrategy,
            named: nameForDevice()
        )
    }
    func testVisitorCodeEmbeddedWhenSuccess() {
        let props: CallVisualizer.VisitorCodeViewController.Props = .init(
            visitorCodeViewProps: .init(
                viewType: .embedded,
                viewState: .success(visitorCode: "12345")
            )
        )
        let visitorCodeViewController = CallVisualizer.VisitorCodeViewController(props: props)
        visitorCodeViewController.view.frame = UIScreen.main.bounds

        assertSnapshot(
            matching: visitorCodeViewController,
            as: .extra3LargeFontStrategy,
            named: nameForDevice()
        )
    }
}
// swiftlint:enable type_name
