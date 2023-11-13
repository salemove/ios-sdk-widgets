@testable import GliaWidgets
import SnapshotTesting
import XCTest

final class SnackBarVoiceOverTests: SnapshotTestCase {
    func testSnackbar() {
        let view = SnackBar.ContentView.mock()
        view.assertSnapshot(as: .accessibilityImage, in: .portrait)
    }
}
