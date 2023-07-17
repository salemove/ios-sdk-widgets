@testable import GliaWidgets
import SnapshotTesting
import XCTest

class BubbleViewLayoutTests: SnapshotTestCase {
    func test_bubble() {
        let bubble = ViewFactory.mock().makeBubbleView()
        bubble.frame = .init(origin: .zero, size: .init(width: 50, height: 50))
        // If shadow will cause failing test locally or on CI, we should disable it.
        assertSnapshot(matching: bubble, as: .image)
    }
}
