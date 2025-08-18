@testable import GliaWidgets
import XCTest

final class AvailabilityTests: XCTestCase {
    typealias Availability = SecureConversations.Availability

    func testListQueuesErrorPassedToResult() async throws {
        var env = Availability.Environment.failing
        let expectedError = CoreSdkClient.SalemoveError.mock()
        env.getQueues = { throw expectedError }
        env.isAuthenticated = { true }
        env.queuesMonitor = .mock(getQueues: env.getQueues)
        let queueIds = [UUID.mock.uuidString]
        let availability = Availability(environment: env)
        do {
            _ = try await availability.checkSecureConversationsAvailability(for: queueIds)
            XCTFail("Expected failure, got success")
        } catch let error as CoreSdkClient.SalemoveError {
            XCTAssertEqual(error, expectedError)
        } catch {
            XCTFail("Unexpected error type: \(error)")
        }
    }

    func testEmptyQueueStatus() async throws {
        var env = Availability.Environment.failing
        env.getQueues = { [] }
        var logger = CoreSdkClient.Logger.failing
        logger.prefixedClosure = { _ in logger }
        logger.warningClosure = { _, _, _, _ in }
        env.log = logger
        env.isAuthenticated = { true }
        env.queuesMonitor = .mock(getQueues: env.getQueues)
        env.getCurrentEngagement = { .mock() }
        let queueIds = [UUID.mock.uuidString]
        let availability = Availability(environment: env)
        let status = try await availability.checkSecureConversationsAvailability(for: queueIds)
        XCTAssertEqual(status, .unavailable(.emptyQueue))
    }

    func testUnauthenticatedQueueStatus() async throws {
        var env = Availability.Environment.failing
        env.getQueues = { [] }
        var logger = CoreSdkClient.Logger.failing
        logger.prefixedClosure = { _ in logger }
        logger.warningClosure = { _, _, _, _ in }
        env.log = logger
        env.isAuthenticated = { false }
        env.queuesMonitor = .mock(getQueues: env.getQueues)
        let queueIds = [UUID.mock.uuidString]
        let availability = Availability(environment: env)
        let status = try await availability.checkSecureConversationsAvailability(for: queueIds)
        XCTAssertEqual(status, .unavailable(.unauthenticated))
    }

    func testAvailableQueueStatus() async throws {
        var env = Availability.Environment.failing
        let queueId = UUID.mock.uuidString
        let mockQueue: Queue = .mock(id: queueId, status: .open, media: [.messaging])
        env.getQueues = { [mockQueue] }
        var logger = CoreSdkClient.Logger.failing
        logger.prefixedClosure = { _ in logger }
        logger.infoClosure = { _, _, _, _ in }
        env.log = logger
        env.isAuthenticated = { true }
        env.queuesMonitor = .mock(getQueues: env.getQueues)
        let availability = Availability(environment: env)
        let status = try await availability.checkSecureConversationsAvailability(for: [queueId])
        switch status {
        case .available(let queueIds):
            XCTAssertEqual(queueIds, .queues(queueIds: [queueId]))
        case .unavailable(let unavailabilityReason):
            XCTFail("Result should be `.success(.available)`")
        }
    }

    func testEmptyQueueStatusIfQueueIdsAreDifferent() async throws {
        var env = Availability.Environment.failing
        let generateUUID = UUID.incrementing
        let queueIds = [generateUUID().uuidString]
        let mockQueue: Queue = .mock(id: generateUUID().uuidString, status: .open, media: [.messaging])
        env.getQueues = { [mockQueue] }
        var logger = CoreSdkClient.Logger.failing
        logger.prefixedClosure = { _ in logger }
        logger.warningClosure = { _, _, _, _ in }
        env.log = logger
        env.isAuthenticated = { true }
        env.queuesMonitor = .mock(getQueues: env.getQueues)
        env.getCurrentEngagement = { .mock() }
        let availability = Availability(environment: env)
        let status = try await availability.checkSecureConversationsAvailability(for: queueIds)
        XCTAssertEqual(status, .unavailable(.emptyQueue))
    }

    func testEmptyQueueStatusIfQueueStatusIsClosed() async throws {
        var env = Availability.Environment.failing
        let generateUUID = UUID.incrementing
        let queueId = generateUUID().uuidString
        let mockQueue: Queue = .mock(id: queueId, status: .closed, media: [.messaging])
        env.getQueues = { [mockQueue] }
        var logger = CoreSdkClient.Logger.failing
        logger.prefixedClosure = { _ in logger }
        logger.warningClosure = { _, _, _, _ in }
        env.log = logger
        env.isAuthenticated = { true }
        env.queuesMonitor = .mock(getQueues: env.getQueues)
        env.getCurrentEngagement = { .mock() }
        let availability = Availability(environment: env)
        let status = try await availability.checkSecureConversationsAvailability(for: [queueId])
        XCTAssertEqual(status, .unavailable(.emptyQueue))
    }

    func testEmptyQueueStatusIfMediaDoesNotContainMessaging() async throws {
        var env = Availability.Environment.failing
        let generateUUID = UUID.incrementing
        let queueId = generateUUID().uuidString
        let mockQueue: Queue = .mock(id: queueId, status: .closed, media: [.text])
        env.getQueues = { [mockQueue] }
        env.getCurrentEngagement = { .mock() }
        var logger = CoreSdkClient.Logger.failing
        logger.prefixedClosure = { _ in logger }
        logger.warningClosure = { _, _, _, _ in }
        env.log = logger
        env.isAuthenticated = { true }
        env.queuesMonitor = .mock(getQueues: env.getQueues)
        let availability = Availability(environment: env)
        let status = try await availability.checkSecureConversationsAvailability(for: [queueId])
        XCTAssertEqual(status, .unavailable(.emptyQueue))
    }

    func testAvailableStatusIfNoQueueIsPassed() async throws {
        var env = Availability.Environment.failing
        let queueId = UUID.mock.uuidString
        let mockQueue: Queue = .mock(id: queueId, status: .open, isDefault: true, media: [.messaging])
        env.getQueues = { [mockQueue] }
        var logger = CoreSdkClient.Logger.failing
        logger.prefixedClosure = { _ in logger }
        logger.infoClosure = { _, _, _, _ in }
        logger.warningClosure = { _, _, _, _ in }
        env.log = logger
        env.isAuthenticated = { true }
        env.queuesMonitor = .mock(getQueues: env.getQueues)
        let availability = Availability(environment: env)
        let status = try await availability.checkSecureConversationsAvailability(for: [])
        if case let .available(.queues(queueIds)) = status {
            XCTAssertTrue(true)
        } else {
            XCTFail("Result should be `.success(.available)`")
        }
    }

    func testEmptyQueueStatusStatusIfThereIsNoDefaultQueuesWithProperConditions() async throws {
        var env = Availability.Environment.failing
        let queueId = UUID.mock.uuidString
        let mockQueue: Queue = .mock(id: queueId, status: .closed, isDefault: true, media: [.text])
        env.getQueues = { [mockQueue] }
        var logger = CoreSdkClient.Logger.failing
        logger.prefixedClosure = { _ in logger }
        logger.warningClosure = { _, _, _, _ in }
        env.log = logger
        env.isAuthenticated = { true }
        env.queuesMonitor = .mock(getQueues: env.getQueues)
        env.getCurrentEngagement = { .mock() }
        let availability = Availability(environment: env)
        let status = try await availability.checkSecureConversationsAvailability(for: [])
        XCTAssertEqual(status, .unavailable(.emptyQueue))
    }

    func testAvailableStatusIfTransferredAndCapabilitiesTextTrue() async throws {
        var env = Availability.Environment.failing
        env.getCurrentEngagement = {
            .mock(status: .transferring, capabilities: .init(text: true))
        }
        env.getQueues = { [] }
        var logger = CoreSdkClient.Logger.failing
        logger.prefixedClosure = { _ in logger }
        logger.infoClosure = { _, _, _, _ in }
        logger.warningClosure = { _, _, _, _ in }
        env.log = logger
        env.isAuthenticated = { true }
        env.queuesMonitor = .mock(getQueues: env.getQueues)
        let availability = Availability(environment: env)
        let status = try await availability.checkSecureConversationsAvailability(for: [])
        XCTAssertEqual(status, .available(.transferred))
    }
}
