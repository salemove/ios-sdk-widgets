@testable import GliaWidgets
import XCTest

final class AvailabilityTests: XCTestCase {
    typealias Availability = SecureConversations.Availability

    func testListQueuesErrorPassedToResult() throws {
        var env = Availability.Environment.failing
        let error = CoreSdkClient.SalemoveError.mock()
        env.getQueues = { callback in
            callback(nil, error)
        }
        env.isAuthenticated = { true }
        env.queuesMonitor = .mock(getQueues: env.getQueues)
        let queueIds = [UUID.mock.uuidString]
        let availability = Availability(environment: env)
        var receivedResult: Result<Availability.Status, CoreSdkClient.SalemoveError>?
        availability.checkSecureConversationsAvailability(for: queueIds) { result in
            receivedResult = result
        }
        try XCTAssertEqual(XCTUnwrap(receivedResult), .failure(error))
    }

    func testEmptyQueueStatus() throws {
        var env = Availability.Environment.failing
        env.getQueues = { callback in
            callback([], nil)
        }
        var logger = CoreSdkClient.Logger.failing
        logger.prefixedClosure = { _ in logger }
        logger.warningClosure = { _, _, _, _ in }
        env.log = logger
        env.isAuthenticated = { true }
        env.queuesMonitor = .mock(getQueues: env.getQueues)
        env.getCurrentEngagement = { .mock() }
        let queueIds = [UUID.mock.uuidString]
        let availability = Availability(environment: env)
        var receivedResult: Result<Availability.Status, CoreSdkClient.SalemoveError>?
        availability.checkSecureConversationsAvailability(for: queueIds) { result in
            receivedResult = result
        }
        try XCTAssertEqual(XCTUnwrap(receivedResult), .success(.unavailable(.emptyQueue)))
    }

    func testUnauthenticatedQueueStatus() throws {
        var env = Availability.Environment.failing
        env.getQueues = { callback in
            callback([], nil)
        }
        var logger = CoreSdkClient.Logger.failing
        logger.prefixedClosure = { _ in logger }
        logger.warningClosure = { _, _, _, _ in }
        env.log = logger
        env.isAuthenticated = { false }
        env.queuesMonitor = .mock(getQueues: env.getQueues)
        let queueIds = [UUID.mock.uuidString]
        let availability = Availability(environment: env)
        var receivedResult: Result<Availability.Status, CoreSdkClient.SalemoveError>?
        availability.checkSecureConversationsAvailability(for: queueIds) { result in
            receivedResult = result
        }
        try XCTAssertEqual(XCTUnwrap(receivedResult), .success(.unavailable(.unauthenticated)))
    }

    func testAvailableQueueStatus() throws {
        var env = Availability.Environment.failing
        let queueId = UUID.mock.uuidString
        env.getQueues = { callback in
            callback([.mock(id: queueId, status: .open, media: [.messaging])], nil)
        }
        var logger = CoreSdkClient.Logger.failing
        logger.prefixedClosure = { _ in logger }
        logger.infoClosure = { _, _, _, _ in }
        env.log = logger
        env.isAuthenticated = { true }
        env.queuesMonitor = .mock(getQueues: env.getQueues)
        let availability = Availability(environment: env)
        var receivedResult: Result<Availability.Status, CoreSdkClient.SalemoveError>?
        availability.checkSecureConversationsAvailability(for: [queueId]) { result in
            receivedResult = result
        }
        let result = try XCTUnwrap(receivedResult)
        switch result {
        case let .success(.available(queueIds)):
            XCTAssertEqual(queueIds, .queues(queueIds: [queueId]))
        default:
            XCTFail("Result should be `.success(.available)`")
        }
    }

    func testEmptyQueueStatusIfQueueIdsAreDifferent() throws {
        var env = Availability.Environment.failing
        let generateUUID = UUID.incrementing
        let queueIds = [generateUUID().uuidString]
        env.getQueues = { callback in
            callback([.mock(id: generateUUID().uuidString, status: .open, media: [.messaging])], nil)
        }
        var logger = CoreSdkClient.Logger.failing
        logger.prefixedClosure = { _ in logger }
        logger.warningClosure = { _, _, _, _ in }
        env.log = logger
        env.isAuthenticated = { true }
        env.queuesMonitor = .mock(getQueues: env.getQueues)
        env.getCurrentEngagement = { .mock() }
        let availability = Availability(environment: env)
        var receivedResult: Result<Availability.Status, CoreSdkClient.SalemoveError>?
        availability.checkSecureConversationsAvailability(for: queueIds) { result in
            receivedResult = result
        }
        try XCTAssertEqual(XCTUnwrap(receivedResult), .success(.unavailable(.emptyQueue)))
    }

    func testEmptyQueueStatusIfQueueStatusIsClosed() throws {
        var env = Availability.Environment.failing
        let generateUUID = UUID.incrementing
        let queueId = generateUUID().uuidString
        env.getQueues = { callback in
            callback([.mock(id: queueId, status: .closed, media: [.messaging])], nil)
        }
        var logger = CoreSdkClient.Logger.failing
        logger.prefixedClosure = { _ in logger }
        logger.warningClosure = { _, _, _, _ in }
        env.log = logger
        env.isAuthenticated = { true }
        env.queuesMonitor = .mock(getQueues: env.getQueues)
        env.getCurrentEngagement = { .mock() }
        let availability = Availability(environment: env)
        var receivedResult: Result<Availability.Status, CoreSdkClient.SalemoveError>?
        availability.checkSecureConversationsAvailability(for: [queueId]) { result in
            receivedResult = result
        }
        try XCTAssertEqual(XCTUnwrap(receivedResult), .success(.unavailable(.emptyQueue)))
    }

    func testEmptyQueueStatusIfMediaDoesNotContainMessaging() throws {
        var env = Availability.Environment.failing
        let generateUUID = UUID.incrementing
        let queueId = generateUUID().uuidString
        env.getQueues = { callback in
            callback([.mock(id: queueId, status: .closed, media: [.text])], nil)
        }
        env.getCurrentEngagement = { .mock() }
        var logger = CoreSdkClient.Logger.failing
        logger.prefixedClosure = { _ in logger }
        logger.warningClosure = { _, _, _, _ in }
        env.log = logger
        env.isAuthenticated = { true }
        env.queuesMonitor = .mock(getQueues: env.getQueues)
        let availability = Availability(environment: env)
        var receivedResult: Result<Availability.Status, CoreSdkClient.SalemoveError>?
        availability.checkSecureConversationsAvailability(for: [queueId]) { result in
            receivedResult = result
        }
        try XCTAssertEqual(XCTUnwrap(receivedResult), .success(.unavailable(.emptyQueue)))
    }

    func testAvailableStatusIfNoQueueIsPassed() throws {
        var env = Availability.Environment.failing
        let queueId = UUID.mock.uuidString
        env.getQueues = { callback in
            callback([.mock(id: queueId, status: .open, isDefault: true, media: [.messaging])], nil)
        }
        var logger = CoreSdkClient.Logger.failing
        logger.prefixedClosure = { _ in logger }
        logger.infoClosure = { _, _, _, _ in }
        logger.warningClosure = { _, _, _, _ in }
        env.log = logger
        env.isAuthenticated = { true }
        env.queuesMonitor = .mock(getQueues: env.getQueues)
        let availability = Availability(environment: env)
        var receivedResult: Result<Availability.Status, CoreSdkClient.SalemoveError>?
        availability.checkSecureConversationsAvailability(for: []) { result in
            receivedResult = result
        }
        let result = try XCTUnwrap(receivedResult)
        switch result {
        case let .success(.available(.queues(queueIds))):
            XCTAssertEqual(queueIds, [queueId])
        default:
            XCTFail("Result should be `.success(.available)`")
        }
    }

    func testEmptyQueueStatusStatusIfThereIsNoDefaultQueuesWithProperConditions() throws {
        var env = Availability.Environment.failing
        let queueId = UUID.mock.uuidString
        env.getQueues = { callback in
            callback([.mock(id: queueId, status: .closed, isDefault: true, media: [.text])], nil)
        }
        var logger = CoreSdkClient.Logger.failing
        logger.prefixedClosure = { _ in logger }
        logger.warningClosure = { _, _, _, _ in }
        env.log = logger
        env.isAuthenticated = { true }
        env.queuesMonitor = .mock(getQueues: env.getQueues)
        env.getCurrentEngagement = { .mock() }
        let availability = Availability(environment: env)
        var receivedResult: Result<Availability.Status, CoreSdkClient.SalemoveError>?
        availability.checkSecureConversationsAvailability(for: []) { result in
            receivedResult = result
        }
        try XCTAssertEqual(XCTUnwrap(receivedResult), .success(.unavailable(.emptyQueue)))
    }

    func testAvailableStatusIfTransferredAndCapabilitiesTextTrue() throws {
        var env = Availability.Environment.failing
        env.getCurrentEngagement = {
            .mock(status: .transferring, capabilities: .init(text: true))
        }
        env.getQueues = { callback in
            callback([], nil)
        }
        var logger = CoreSdkClient.Logger.failing
        logger.prefixedClosure = { _ in logger }
        logger.infoClosure = { _, _, _, _ in }
        logger.warningClosure = { _, _, _, _ in }
        env.log = logger
        env.isAuthenticated = { true }
        env.queuesMonitor = .mock(getQueues: env.getQueues)
        let availability = Availability(environment: env)
        var receivedResult: Result<Availability.Status, CoreSdkClient.SalemoveError>?
        availability.checkSecureConversationsAvailability(for: []) { result in
            receivedResult = result
        }
        let result = try XCTUnwrap(receivedResult)
        switch result {
        case let .success(status):
            XCTAssertEqual(status, .available(.transferred))
        default:
            XCTFail("Result should be `.success(.available)`. Got `\(result)` instead.")
        }
    }
}
