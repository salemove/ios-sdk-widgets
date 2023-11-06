import Foundation
import XCTest

@testable import GliaWidgets

final class SerialQueueTests: XCTestCase {
    var queue = SerialQueue()

    override func setUp() {
        queue = .init()
        super.setUp()
    }

    func test_addOperation() {
        var performed = [String]()
        queue.addOperation(
            .traceable {
                performed.append("operation-performed")
            }
        )
        XCTAssertEqual(performed, ["operation-performed"])
        XCTAssertTrue(queue.queue.isEmpty)
    }

    func test_addOperationSequence() {
        var performed = [String]()
        queue.addOperation(
            .traceable {
                performed.append("operation-a")
            }
        )
        queue.addOperation(
            .traceable {
                performed.append("operation-b")
            }
        )
        XCTAssertEqual(performed, ["operation-a", "operation-b"])
        XCTAssertTrue(queue.queue.isEmpty)
    }
}

extension SerialQueue.Operation {
    static func traceable(onPerform: @escaping () -> Void) -> SerialQueue.Operation {
        return .init { done in
            onPerform()
            done()
        }
    }
}
