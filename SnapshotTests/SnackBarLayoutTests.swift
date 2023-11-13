@testable import GliaWidgets
import SnapshotTesting
import XCTest

final class SnackBarLayoutTests: SnapshotTestCase {
    func testSnackbar() {
        let view = SnackBar.ContentView.mock()
        view.assertSnapshot(as: .image, in: .portrait)
        view.assertSnapshot(as: .image, in: .landscape)
    }
}
