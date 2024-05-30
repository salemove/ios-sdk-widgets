@testable import GliaWidgets
import SnapshotTesting
import XCTest

final class CustomCardContainerViewLayoutTests: SnapshotTestCase {
    func test_customCardContainer() {
        let containerView = CustomCardContainerView(
            style: .mock(
                placeholderImage: .mock,
                placeholderBackgroundColor: .fill(color: .lightGray),
                imageBackgroundColor: .fill(color: .lightGray)
            ),
            environment: .mock(imageViewCache: .mock)
        )
        containerView.backgroundColor = .white
        containerView.frame = .init(
            origin: .zero,
            size: .init(
                width: 300,
                height: 100
            )
        )
        let contentView = UIView()
        contentView.backgroundColor = .cyan
        containerView.addContentView(contentView)
        containerView.assertSnapshot(as: .image)
    }
}
