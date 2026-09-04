import XCTest
import Combine
@_spi(GliaWidgets) import GliaCoreSDK

@testable import GliaWidgets

class QueuesMonitorTests: XCTestCase {
    private enum Call {
        case getQueues
        case subscribeForQueuesUpdates
    }

    private var monitor: QueuesMonitor!
    private var cancellables: CancelBag!

    override func setUp() {
        super.setUp()
        cancellables = .init()

        monitor = QueuesMonitor(environment: .mock)
    }

    override func tearDown() {
        monitor = nil
        super.tearDown()
    }

    // MARK: Fetch and Motitor queues
    func test_fetchAndMonitorQueuesWithQueuesUpdatesWithQueuesList() async throws {
        var envCalls: [Call] = []
        let expectedLogMessage = "Setting up queues. 1 out of 1 queues provided by an integrator match with site queues."
        var receivedLogMessage = ""
        let mockQueueId = "mock_queue_id"
        let expectedObservedQueues = [Queue.mock(id: mockQueueId)]
        let mockQueues = [expectedObservedQueues[0], Queue.mock(id: UUID().uuidString)]
        monitor.environment.logger.infoClosure = { logMessage, _, _, _ in
            receivedLogMessage = logMessage as? String ?? ""
        }
        monitor.environment.getQueues = {
            envCalls.append(.getQueues)
            return mockQueues
        }
        monitor.environment.subscribeForQueuesUpdates = { _ in
            envCalls.append(.subscribeForQueuesUpdates)
            return Self.stream(yielding: expectedObservedQueues[0])
        }

        var receivedQueues: [GliaWidgets.Queue]?
        monitor.$state
            .sink { state in
                if case let .updated(queues) = state {
                    receivedQueues = queues
                }
            }
            .store(in: &cancellables)

        _ = try await monitor.fetchAndMonitorQueues(queuesIds: [mockQueueId])
        await waitUntil { envCalls.count == 2 }

        XCTAssertEqual(receivedQueues, expectedObservedQueues)
        XCTAssertEqual(envCalls, [.getQueues, .subscribeForQueuesUpdates])
        XCTAssertEqual(receivedLogMessage, expectedLogMessage)
    }

    func test_fetchAndMonitorQueuesWithWrongQueueIdsReturnsUpdatesWithDefaultQueue() async throws {
        var envCalls: [Call] = []
        let expectedLogMessages = [
            "Setting up queues. 0 out of 1 queues provided by an integrator match with site queues.",
            "Setting up queues. Integrator specified an empty list of queues.",
            "Setting up queues. Using 1 default queues."
        ]
        var receivedLogMessage: [String] = []
        let mockedQueue = Queue.mock(isDefault: true)
        let expectedObservedQueues = [mockedQueue]
        let mockQueues = [expectedObservedQueues[0], Queue.mock()]
        monitor.environment.logger.infoClosure = { logMessage, _, _, _ in
            receivedLogMessage.append(logMessage as? String ?? "")
        }
        monitor.environment.getQueues = {
            envCalls.append(.getQueues)
            return mockQueues
        }
        monitor.environment.subscribeForQueuesUpdates = { _ in
            envCalls.append(.subscribeForQueuesUpdates)
            return Self.stream(yielding: mockedQueue)
        }

        var receivedQueues: [GliaWidgets.Queue]?
        monitor.$state
            .sink { state in
                if case let .updated(queues) = state {
                    receivedQueues = queues
                }
            }
            .store(in: &cancellables)

        _ = try await monitor.fetchAndMonitorQueues(queuesIds: ["1"])
        await waitUntil { envCalls.count == 2 }

        XCTAssertEqual(receivedQueues, expectedObservedQueues)
        XCTAssertEqual(envCalls, [.getQueues, .subscribeForQueuesUpdates])
        XCTAssertEqual(expectedLogMessages, receivedLogMessage)
    }

    func test_fetchAndMonitorQueuesgetQueuesReturnsError() async throws {
        var envCalls: [Call] = []
        let expectedErrorLog = "Setting up queues. Failed to get site queues: mock"
        var receivedErrorLog = ""
        let expectedError = CoreSdkClient.SalemoveError.mock()
        monitor.environment.logger.errorClosure = { logMessage, _, _, _ in
            receivedErrorLog = logMessage as? String ?? ""
        }
        monitor.environment.getQueues = {
            envCalls.append(.getQueues)
            throw expectedError
        }
        monitor.environment.subscribeForQueuesUpdates = { _ in
            envCalls.append(.subscribeForQueuesUpdates)
            return Self.finishedStream()
        }

        var receivedError: CoreSdkClient.SalemoveError?
        monitor.$state
            .sink { state in
                if case let .failed(error as CoreSdkClient.SalemoveError) = state {
                    receivedError = error
                }
            }
            .store(in: &cancellables)

        do {
            _ = try await monitor.fetchAndMonitorQueues(queuesIds: ["1"])
            XCTFail("Test should throw error")
        } catch {
            XCTAssertEqual(receivedError, expectedError)
            XCTAssertEqual(expectedErrorLog, receivedErrorLog)
        }
        XCTAssertEqual(envCalls, [.getQueues])
    }

    func test_fetchAndMonitorQueuesWithQueuesAndReceiveUpdatedQueueSuccess() async throws {
        var envCalls: [Call] = []

        let mockQueueId = "mock_queue_id"
        // We use this date value to ensure that
        // `expectedUpdatedQueue.lastUpdated > expectedObservedQueue.lastUpdated`.
        // Otherwise, the `expectedUpdatedQueue` is ignored during the `QueuesMonitor.updateQueue(_:)` call.
        let date = Date()
        let expectedObservedQueue = Queue.mock(id: mockQueueId, status: .open, lastUpdated: date)
        let expectedUpdatedQueue = Queue.mock(id: mockQueueId, status: .open, lastUpdated: date.advanced(by: 1))
        let mockQueues = [expectedObservedQueue, Queue.mock(id: UUID().uuidString)]

        monitor.environment.getQueues = {
            envCalls.append(.getQueues)
            return mockQueues
        }
        monitor.environment.subscribeForQueuesUpdates = { [expectedUpdatedQueue] _ in
            envCalls.append(.subscribeForQueuesUpdates)
            return Self.stream(yielding: expectedUpdatedQueue)
        }

        var receivedQueues: [GliaWidgets.Queue]?
        var receivedUpdatedQueue: GliaWidgets.Queue?
        monitor.$state
            .receive(on: CoreSdkClient.AnyCombineScheduler.mock.mainScheduler)
            // Drop initial .idle and .updated with listed queues state update
            .dropFirst(2)
            .sink { state in
                if case let .updated(queues) = state {
                    receivedQueues = queues
                    receivedUpdatedQueue = queues[0]
                }
            }
            .store(in: &cancellables)

        _ = try await monitor.fetchAndMonitorQueues(queuesIds: [mockQueueId])
        await waitUntil { receivedUpdatedQueue != nil }

        XCTAssertEqual(receivedQueues, [expectedUpdatedQueue])
        XCTAssertEqual(receivedUpdatedQueue?.status, .open)
        XCTAssertEqual(envCalls, [.getQueues, .subscribeForQueuesUpdates])
    }

    func test_fetchAndMonitorQueuesWithQueuesStopsPreviousMonitoring() async throws {
        var envCalls: [Call] = []
        let firstStreamCancelled = expectation(description: "First queue updates stream is cancelled")
        var subscriptionCount = 0

        let mockQueueId = "mock_queue_id"
        // We use this date value to ensure that
        // `expectedUpdatedQueue.lastUpdated > expectedObservedQueue.lastUpdated`.
        // Otherwise, the `expectedUpdatedQueue` is ignored during the `QueuesMonitor.updateQueue(_:)` call.
        let date = Date()
        let expectedObservedQueue = Queue.mock(id: mockQueueId, status: .open, lastUpdated: date)
        let expectedUpdatedQueue = Queue.mock(id: mockQueueId, status: .open, lastUpdated: date.advanced(by: 1))
        let mockQueues = [expectedObservedQueue, Queue.mock(id: UUID().uuidString)]

        monitor.environment.getQueues = {
            envCalls.append(.getQueues)
            return mockQueues
        }
        monitor.environment.subscribeForQueuesUpdates = { _ in
            envCalls.append(.subscribeForQueuesUpdates)
            subscriptionCount += 1
            let isFirstSubscription = subscriptionCount == 1
            return AsyncThrowingStream { continuation in
                continuation.onTermination = { termination in
                    guard isFirstSubscription, case .cancelled = termination else { return }
                    firstStreamCancelled.fulfill()
                }
                continuation.yield(expectedUpdatedQueue)
            }
        }

        var receivedQueues: [GliaWidgets.Queue]?
        var receivedUpdatedQueue: GliaWidgets.Queue?
        monitor.$state
            .receive(on: CoreSdkClient.AnyCombineScheduler.mock.mainScheduler)
            // Drop initial .idle and .updated with listed queues state update
            .dropFirst(2)
            .sink { state in
                if case let .updated(queues) = state {
                    receivedQueues = queues
                    receivedUpdatedQueue = queues[0]
                }
            }
            .store(in: &cancellables)

        _ = try await monitor.fetchAndMonitorQueues(queuesIds: [mockQueueId])
        await waitUntil { envCalls.contains(.subscribeForQueuesUpdates) }
        _ = try await monitor.fetchAndMonitorQueues(queuesIds: [mockQueueId])
        await fulfillment(of: [firstStreamCancelled], timeout: 1)
        await waitUntil { envCalls.count == 4 }
        XCTAssertEqual(receivedQueues, [expectedUpdatedQueue])
        XCTAssertEqual(receivedUpdatedQueue?.status, .open)
        XCTAssertEqual(
            envCalls,
            [
                .getQueues,
                .subscribeForQueuesUpdates,
                .getQueues,
                .subscribeForQueuesUpdates
            ]
        )
    }

    func test_fetchAndMonitorQueuesWithQueuesAndReceiveUpdatedQueueError() async throws {
        var envCalls: [Call] = []

        let expectedError = CoreSdkClient.SalemoveError.mock()
        let mockQueues = [Queue.mock()]

        monitor.environment.getQueues = {
            envCalls.append(.getQueues)
            return mockQueues
        }
        monitor.environment.subscribeForQueuesUpdates = { _ in
            envCalls.append(.subscribeForQueuesUpdates)
            return Self.stream(throwing: expectedError)
        }

        var receivedError: CoreSdkClient.SalemoveError?
        monitor.$state
            // Drop initial .idle and .updated with listed queues state update
            .dropFirst(2)
            .sink { state in
                if case let .failed(error as CoreSdkClient.SalemoveError) = state {
                    receivedError = error
                }
            }
            .store(in: &cancellables)

        _ = try await monitor.fetchAndMonitorQueues(queuesIds: [UUID().uuidString])
        await waitUntil { receivedError != nil }

        XCTAssertEqual(receivedError, expectedError)
        XCTAssertEqual(envCalls, [.getQueues, .subscribeForQueuesUpdates])
    }

    // MARK: Stop monitoring
    func test_stopMonitoringSuccess() async throws {
        var envCalls: [Call] = []
        let streamCancelled = expectation(description: "Queue updates stream is cancelled")

        monitor.environment.getQueues = {
            envCalls.append(.getQueues)
            return []
        }
        monitor.environment.subscribeForQueuesUpdates = { _ in
            envCalls.append(.subscribeForQueuesUpdates)
            return AsyncThrowingStream { continuation in
                continuation.onTermination = { termination in
                    guard case .cancelled = termination else { return }
                    streamCancelled.fulfill()
                }
            }
        }

        _ = try await monitor.fetchAndMonitorQueues(queuesIds: ["1"])
        await waitUntil { envCalls.contains(.subscribeForQueuesUpdates) }

        monitor.stopMonitoring()
        await fulfillment(of: [streamCancelled], timeout: 1)

        XCTAssertEqual(envCalls, [.getQueues, .subscribeForQueuesUpdates])
    }

    func test_receiveOlderQueue_doesNotReplaceExistingQueue() async throws {
        var envCalls: [Call] = []
        let mockQueueId = "mock_queue_id"
        let existingQueue = Queue.mock(
            id: mockQueueId,
            lastUpdated: Date() // now
        )
        let olderQueue = Queue.mock(
            id: mockQueueId,
            lastUpdated: Date(timeIntervalSinceNow: -1000)
        )

        monitor.environment.getQueues = {
            envCalls.append(.getQueues)
            return [existingQueue]
        }
        monitor.environment.subscribeForQueuesUpdates = { _ in
            envCalls.append(.subscribeForQueuesUpdates)
            return Self.stream(yielding: olderQueue)
        }
        var receivedQueues: [GliaWidgets.Queue]?
        monitor.$state
            // Drop initial .idle and then .updated after fetching
            .dropFirst(2)
            .sink { state in
                if case let .updated(queues) = state {
                    receivedQueues = queues
                }
            }
            .store(in: &cancellables)

        _ = try await monitor.fetchAndMonitorQueues(queuesIds: [mockQueueId])
        await waitUntil { envCalls.count == 2 }

        XCTAssertEqual(envCalls, [.getQueues, .subscribeForQueuesUpdates])
        XCTAssertEqual(receivedQueues?.count, 1)
        XCTAssertEqual(receivedQueues?.first?.lastUpdated, existingQueue.lastUpdated)
    }

    func test_receiveNewerQueue_updatesExistingQueue() async throws {
        var envCalls: [Call] = []
        let mockQueueId = "mock_queue_id"

        let oldQueue = Queue.mock(
            id: mockQueueId,
            lastUpdated: Date(timeIntervalSinceNow: -1000)
        )

        let newerQueue = Queue.mock(
            id: mockQueueId,
            lastUpdated: Date() // now
        )

        monitor.environment.getQueues = {
            envCalls.append(.getQueues)
            return [oldQueue]
        }
        monitor.environment.subscribeForQueuesUpdates = { _ in
            envCalls.append(.subscribeForQueuesUpdates)
            return Self.stream(yielding: newerQueue)
        }

        var receivedQueues: [GliaWidgets.Queue]?
        monitor.$state
            // Drop initial .idle and then .updated after fetching
            .dropFirst(2)
            .sink { state in
                if case let .updated(queues) = state {
                    receivedQueues = queues
                }
            }
            .store(in: &cancellables)

        _ = try await monitor.fetchAndMonitorQueues(queuesIds: [mockQueueId])
        await waitUntil { receivedQueues != nil }

        XCTAssertEqual(envCalls, [.getQueues, .subscribeForQueuesUpdates])
        XCTAssertEqual(receivedQueues?.count, 1)
        XCTAssertEqual(receivedQueues?.first?.lastUpdated, newerQueue.lastUpdated)
    }

    func test_receiveQueueForUnknownId_appendsQueue() async throws {
        var envCalls: [Call] = []
        let knownQueueId = "known_queue_id"
        let unknownQueueId = "unknown_queue_id"
        let knownQueue = Queue.mock(
            id: knownQueueId,
            lastUpdated: Date()
        )
        let brandNewQueue = Queue.mock(
            id: unknownQueueId,
            lastUpdated: Date()
        )

        monitor.environment.getQueues = {
            envCalls.append(.getQueues)
            return [knownQueue]
        }
        monitor.environment.subscribeForQueuesUpdates = { _ in
            envCalls.append(.subscribeForQueuesUpdates)
            return Self.stream(yielding: brandNewQueue)
        }

        var receivedQueues: [GliaWidgets.Queue]?
        monitor.$state
            // Drop initial .idle and then .updated after fetching
            .dropFirst(2)
            .sink { state in
                if case let .updated(queues) = state {
                    receivedQueues = queues
                }
            }
            .store(in: &cancellables)

        _ = try await monitor.fetchAndMonitorQueues(queuesIds: [knownQueueId])
        await waitUntil { receivedQueues?.count == 2 }

        XCTAssertEqual(envCalls, [.getQueues, .subscribeForQueuesUpdates])
        XCTAssertEqual(receivedQueues?.count, 2)
        XCTAssertTrue(receivedQueues?.contains(where: { $0.id == knownQueueId }) == true)
        XCTAssertTrue(receivedQueues?.contains(where: { $0.id == unknownQueueId }) == true)
    }
}

private extension QueuesMonitorTests {
    static func stream(yielding queue: GliaWidgets.Queue) -> AsyncThrowingStream<GliaWidgets.Queue, Error> {
        AsyncThrowingStream { continuation in
            continuation.yield(queue)
            continuation.finish()
        }
    }

    static func stream(throwing error: Error) -> AsyncThrowingStream<GliaWidgets.Queue, Error> {
        AsyncThrowingStream { continuation in
            continuation.finish(throwing: error)
        }
    }

    static func finishedStream() -> AsyncThrowingStream<GliaWidgets.Queue, Error> {
        AsyncThrowingStream { continuation in
            continuation.finish()
        }
    }
}
