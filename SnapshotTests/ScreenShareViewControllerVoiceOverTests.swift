import AccessibilitySnapshot
@testable import GliaWidgets
import SnapshotTesting
import XCTest

final class ScreenShareViewControllerVoiceOverTests: SnapshotTestCase {
    func testScreenShareViewController() {
        let model: CallVisualizer.ScreenSharingView.Model = .mock()
		let viewController: CallVisualizer.ScreenSharingViewController = .init(model: model)
        viewController.assertSnapshot(as: .accessibilityImage)
    }
}
