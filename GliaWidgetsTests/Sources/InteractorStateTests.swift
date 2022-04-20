import XCTest

@testable import GliaWidgets

class InteractorStateTests: XCTestCase {
    func test_engagedWithSameOperatorIsEqualState() throws {
        let engagedOperator: CoreSdkClient.Operator = .mock()
        let state1: InteractorState = .engaged(engagedOperator)
        let state2: InteractorState = .engaged(engagedOperator)

        XCTAssertEqual(state1, state2)
    }
    
    func test_engagedWithDifferentOperatorIsNotEqualState() throws {
        let state1: InteractorState = .engaged(.mock())
        let state2: InteractorState = .engaged(.mock())

        XCTAssertNotEqual(state1, state2)
    }
}
