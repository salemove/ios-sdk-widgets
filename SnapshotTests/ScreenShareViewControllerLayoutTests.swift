@testable import GliaWidgets
import SnapshotTesting
import XCTest

final class ScreenShareViewControllerLayoutTests: SnapshotTestCase {
    func testScreenShareViewController() {
        let model: CallVisualizer.ScreenSharingView.Model = .mock()
        let viewController: CallVisualizer.ScreenSharingViewController = .init(model: model)
        viewController.assertSnapshot(as: .image, in: .portrait)
        viewController.assertSnapshot(as: .image, in: .landscape)
    }
}
