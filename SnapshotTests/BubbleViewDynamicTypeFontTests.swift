import AccessibilitySnapshot
@testable import GliaWidgets
import SnapshotTesting
import XCTest

final class BubbleViewDynamicTypeFontTests: SnapshotTestCase {
    func test_bubble_extra3Large() {
        let bubble = ViewFactory.mock().makeBubbleView()
        bubble.frame = .init(origin: .zero, size: .init(width: 50, height: 50))
        // If shadow will cause failing test locally or on CI, we should disable it.
        assertSnapshot(
            matching: bubble,
            as: .extra3LargeFontStrategy
        )
    }
}
