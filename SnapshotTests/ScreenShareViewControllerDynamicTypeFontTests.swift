@testable import GliaWidgets
import SnapshotTesting
import XCTest

// swiftlint:disable type_name
final class ScreenShareViewControllerDynamicTypeFontTests: SnapshotTestCase {
    func testScreenShareViewController_extra3Large() {
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
        screenShareViewController.assertSnapshot(as: .extra3LargeFont, in: .portrait)
        screenShareViewController.assertSnapshot(as: .extra3LargeFont, in: .landscape)
    }
}
// swiftlint:enable type_name
