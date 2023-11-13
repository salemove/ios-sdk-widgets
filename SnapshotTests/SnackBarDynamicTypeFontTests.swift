@testable import GliaWidgets
import SnapshotTesting
import XCTest

final class SnackBarDynamicTypeFontTests: SnapshotTestCase {
    func testSnackbar() {
        let view = SnackBar.ContentView.mock()
        view.assertSnapshot(as: .extra3LargeFont, in: .portrait)
        view.assertSnapshot(as: .extra3LargeFont, in: .landscape)
    }
}
