@testable import GliaWidgets
import SnapshotTesting
import XCTest

final class BubbleWindowLayoutTests: XCTestCase {
    func test_bubbleWindow() {
        let bubble = ViewFactory.mock().makeBubbleView()
        bubble.frame = .init(origin: .zero, size: .init(width: 50, height: 50))
        let bubbleWindow = BubbleWindow(
            bubbleView: bubble,
            environment: .init(
                uiScreen: .mock,
                uiApplication: .mock
            )
        )
        bubbleWindow.makeKeyAndVisible()
        bubbleWindow.assertSnapshot(as: .image, in: .portrait)
        bubbleWindow.assertSnapshot(as: .image, in: .landscape)
    }
}
