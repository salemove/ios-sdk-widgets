@testable import GliaWidgets
import SnapshotTesting
import XCTest

final class MediaPickerDynamicFontTests: SnapshotTestCase {
    func test_mediaPicker() {
        let containerView = UIView()
        let size: CGSize = .init(width: 300, height: 140)
        containerView.frame = .init(origin: .zero, size: size)

        let listView = AttachmentSourceListView(with: .mock())
        let edgeInsets: UIEdgeInsets = .init(
            top: 0,
            left: 0,
            bottom: 0,
            right: 15
        )

        let mediaPickerView: PopoverViewController = .init(
            with: listView,
            presentFrom: containerView,
            contentInsets: edgeInsets
        )

        mediaPickerView.view.frame = .init(origin: .zero, size: size)
        mediaPickerView.view.assertSnapshot(as: .extra3LargeFont, in: .portrait)
        mediaPickerView.view.assertSnapshot(as: .extra3LargeFont, in: .landscape)
    }
}
