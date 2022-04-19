@testable import GliaWidgets
import XCTest

class UIViewControllerCoordinatorTests: XCTestCase {
    func test_coordinate() {
        let c1: UIViewControllerCoordinator = .mock
        let c2: UIViewControllerCoordinator = .mock
        let vc = c1.coordinate(to: c2)

        XCTAssertEqual([c2.id: c2], c1.children)
        vc.onDeinit?()
        XCTAssertEqual([:], c1.children)
    }
}
