@testable import GliaWidgets
import XCTest

final class AvailabilityTests: XCTestCase {
    typealias Availability = SecureConversations.Availability

    func testEmptyQueueStatus() throws {
        var env = Availability.Environment.failing
        env.listQueues = { callback in
            callback([], nil)
        }
        env.isAuthenticated = { true }
        env.queueIds = [UUID.mock.uuidString]
        let availability = Availability.init(environment: env)
        var receivedResult: Result<Availability.Status, CoreSdkClient.SalemoveError>?
        availability.checkSecureConversationsAvailability { result in
            receivedResult = result
        }
        try XCTAssertEqual(XCTUnwrap(receivedResult), .success(.unavailable(.emptyQueue)))
    }

    func testUnauthenticatedQueueStatus() throws {
        var env = Availability.Environment.failing
        env.listQueues = { callback in
            callback([], nil)
        }
        env.isAuthenticated = { false }
        env.queueIds = [UUID.mock.uuidString]
        let availability = Availability.init(environment: env)
        var receivedResult: Result<Availability.Status, CoreSdkClient.SalemoveError>?
        availability.checkSecureConversationsAvailability { result in
            receivedResult = result
        }
        try XCTAssertEqual(XCTUnwrap(receivedResult), .success(.unavailable(.unauthenticated)))
    }
}
