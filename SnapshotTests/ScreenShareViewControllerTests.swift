import AccessibilitySnapshot
@testable import GliaWidgets
import SnapshotTesting
import XCTest

class ScreenShareViewControllerTests: SnapshotTestCase {
    func testScreenShareViewController() {
        let props: CallVisualizer.ScreenSharingViewController.Props = .init(
            screenSharingViewProps: .init(
                style: .mock(),
                header: .mock(
                    title: L10n.CallVisualizer.ScreenSharing.title,
                    backButton: .init(style: .mock(image: Asset.back.image))
                ),
                endScreenSharing: .mock()
            )
        )
        let screenShareViewController = CallVisualizer.ScreenSharingViewController(props: props)
        screenShareViewController.view.frame = UIScreen.main.bounds

        assertSnapshot(
            matching: screenShareViewController,
            as: .accessibilityImage(precision: Self.possiblePrecision),
            named: nameForDevice()
        )

    }
}
