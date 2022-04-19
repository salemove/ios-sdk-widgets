@testable import GliaWidgets
import XCTest

class UIViewControllerTests: XCTestCase {
    private var deallocationExpectations: [XCTestExpectation] = []
    
    override func tearDown() {
        wait(for: self.deallocationExpectations, timeout: 1)
    }

    func test_deinit() {
        var viewController: UIViewController? = UIViewController()
        let expectation = XCTestExpectation(
            description: "viewController deallocated"
        )

        viewController?.onDeinit = {
            expectation.fulfill()
        }

        XCTAssertNotEqual(viewController, nil)
        viewController = nil
        
        deallocationExpectations.append(expectation)
    }
}
