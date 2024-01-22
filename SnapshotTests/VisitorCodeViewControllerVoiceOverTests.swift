import AccessibilitySnapshot
@testable import GliaWidgets
import SnapshotTesting
import XCTest

final class VisitorCodeViewControllerVoiceOverTests: SnapshotTestCase {
    func testVisitorCodeAlertWhenLoading() {
        let props: CallVisualizer.VisitorCodeViewController.Props = .init(
            visitorCodeViewProps: .init(
                viewType: .alert(closeButtonTap: .nop),
                viewState: .loading
            )
        )
        let viewController = CallVisualizer.VisitorCodeViewController(props: props, environment: .mock)
        viewController.assertSnapshot(as: .accessibilityImage)
    }

    func testVisitorCodeAlertWhenError() {
        let props: CallVisualizer.VisitorCodeViewController.Props = .init(
            visitorCodeViewProps: .init(
                viewType: .alert(closeButtonTap: .nop),
                viewState: .error(refreshTap: .nop)
            )
        )
        let viewController = CallVisualizer.VisitorCodeViewController(props: props, environment: .mock)
        viewController.assertSnapshot(as: .accessibilityImage)
    }

    func testVisitorCodeAlertWhenSuccess() {
        let props: CallVisualizer.VisitorCodeViewController.Props = .init(
            visitorCodeViewProps: .init(
                viewType: .alert(closeButtonTap: .nop),
                viewState: .success(visitorCode: "12345")
            )
        )
        let viewController = CallVisualizer.VisitorCodeViewController(props: props, environment: .mock)
        viewController.assertSnapshot(as: .accessibilityImage)
    }

    func testVisitorCodeEmbeddedWhenLoading() {
        let props: CallVisualizer.VisitorCodeViewController.Props = .init(
            visitorCodeViewProps: .init(
                viewType: .embedded,
                viewState: .loading
            )
        )
        let viewController = CallVisualizer.VisitorCodeViewController(props: props, environment: .mock)
        viewController.assertSnapshot(as: .accessibilityImage)
    }

    func testVisitorCodeEmbeddedWhenError() {
        let props: CallVisualizer.VisitorCodeViewController.Props = .init(
            visitorCodeViewProps: .init(
                viewType: .embedded,
                viewState: .error(refreshTap: .nop)
            )
        )
        let viewController = CallVisualizer.VisitorCodeViewController(props: props, environment: .mock)
        viewController.assertSnapshot(as: .accessibilityImage)
    }
    func testVisitorCodeEmbeddedWhenSuccess() {
        let props: CallVisualizer.VisitorCodeViewController.Props = .init(
            visitorCodeViewProps: .init(
                viewType: .embedded,
                viewState: .success(visitorCode: "12345")
            )
        )
        let viewController = CallVisualizer.VisitorCodeViewController(props: props, environment: .mock)
        viewController.assertSnapshot(as: .accessibilityImage)
    }
}
