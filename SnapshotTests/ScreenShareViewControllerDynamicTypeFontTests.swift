@testable import GliaWidgets
import SnapshotTesting
import XCTest

// swiftlint:disable type_name
final class ScreenShareViewControllerDynamicTypeFontTests: SnapshotTestCase {
    func testScreenShareViewController_extra3Large() {
        let model: CallVisualizer.ScreenSharingView.Model = .mock()
        let viewController: CallVisualizer.ScreenSharingViewController = .init(model: model)
        viewController.assertSnapshot(as: .extra3LargeFont, in: .portrait)
        viewController.assertSnapshot(as: .extra3LargeFont, in: .landscape)
    }
}
// swiftlint:enable type_name
