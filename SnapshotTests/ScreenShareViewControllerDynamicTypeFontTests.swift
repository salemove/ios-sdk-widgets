@testable import GliaWidgets
import SnapshotTesting
import XCTest

// swiftlint:disable type_name
final class ScreenShareViewControllerDynamicTypeFontTests: SnapshotTestCase {
    func testScreenShareViewController_extra3Large() {
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
            as: .extra3LargeFontStrategy,
            named: nameForDevice()
        )
    }
}
// swiftlint:enable type_name
