@testable import GliaWidgets
import SnapshotTesting
import XCTest

final class BubbleViewLayoutTests: SnapshotTestCase {
    func test_bubble() {
        let bubble = ViewFactory.mock().makeBubbleView()
        bubble.frame = .init(origin: .zero, size: .init(width: 50, height: 50))
        assertSnapshot(
            matching: bubble,
            as: .image
        )
        assertSnapshot(
            matching: bubble,
            as: .imageLandscape,
            named: nameForDevice(.landscape)
        )
    }
}
