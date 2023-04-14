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
        let availability = Availability(environment: env)
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
        let availability = Availability(environment: env)
        var receivedResult: Result<Availability.Status, CoreSdkClient.SalemoveError>?
        availability.checkSecureConversationsAvailability { result in
            receivedResult = result
        }
        try XCTAssertEqual(XCTUnwrap(receivedResult), .success(.unavailable(.unauthenticated)))
    }

    func testAvailableQueueStatus() throws {
        var env = Availability.Environment.failing
        let queueId = UUID.mock.uuidString
        env.listQueues = { callback in
            callback([.mock(id: queueId, status: .open, media: [.messaging])], nil)
        }
        env.isAuthenticated = { true }
        env.queueIds = [UUID.mock.uuidString]
        let availability = Availability(environment: env)
        var receivedResult: Result<Availability.Status, CoreSdkClient.SalemoveError>?
        availability.checkSecureConversationsAvailability { result in
            receivedResult = result
        }
        try XCTAssertEqual(XCTUnwrap(receivedResult), .success(.available))
    }

    func testEmptyQueueStatusIfQueueIdsAreDifferent() throws {
        var env = Availability.Environment.failing
        let generateUUID = UUID.incrementing
        env.listQueues = { callback in
            callback([.mock(id: generateUUID().uuidString, status: .open, media: [.messaging])], nil)
        }
        env.isAuthenticated = { true }
        env.queueIds = []
        let availability = Availability(environment: env)
        var receivedResult: Result<Availability.Status, CoreSdkClient.SalemoveError>?
        availability.checkSecureConversationsAvailability { result in
            receivedResult = result
        }
        try XCTAssertEqual(XCTUnwrap(receivedResult), .success(.unavailable(.emptyQueue)))
    }

    func testEmptyQueueStatusIfQueueStatusIsClosed() throws {
        var env = Availability.Environment.failing
        let generateUUID = UUID.incrementing
        let queueId = generateUUID().uuidString
        env.listQueues = { callback in
            callback([.mock(id: queueId, status: .closed, media: [.messaging])], nil)
        }
        env.isAuthenticated = { true }
        env.queueIds = []
        let availability = Availability(environment: env)
        var receivedResult: Result<Availability.Status, CoreSdkClient.SalemoveError>?
        availability.checkSecureConversationsAvailability { result in
            receivedResult = result
        }
        try XCTAssertEqual(XCTUnwrap(receivedResult), .success(.unavailable(.emptyQueue)))
    }

    func testEmptyQueueStatusIfMediaDoesNotContainMessaging() throws {
        var env = Availability.Environment.failing
        let generateUUID = UUID.incrementing
        let queueId = generateUUID().uuidString
        env.listQueues = { callback in
            callback([.mock(id: queueId, status: .closed, media: [.text])], nil)
        }
        env.isAuthenticated = { true }
        env.queueIds = []
        let availability = Availability(environment: env)
        var receivedResult: Result<Availability.Status, CoreSdkClient.SalemoveError>?
        availability.checkSecureConversationsAvailability { result in
            receivedResult = result
        }
        try XCTAssertEqual(XCTUnwrap(receivedResult), .success(.unavailable(.emptyQueue)))
    }
}
