import AccessibilitySnapshot
@testable import GliaWidgets
import SnapshotTesting
import XCTest

class ScreenShareViewControllerTests: SnapshotTestCase {
    func testScreenShareViewController() {
        let theme = Theme()
        let font = theme.font
        let props: CallVisualizer.ScreenSharingViewController.Props = .init(
            screenSharingViewProps: .init(
                style: .mock(
                    messageTextFont: font.header2,
                    buttonTitleFont: font.bodyText
                ),
                header: .mock(
                    title: L10n.CallVisualizer.ScreenSharing.title,
                    backButton: .init(style: .mock(image: Asset.back.image))
                ),
                endScreenSharing: .mock(style: .mock(titleFont: font.bodyText))
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
