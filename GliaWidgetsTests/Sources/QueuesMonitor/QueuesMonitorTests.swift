import XCTest
import Combine
import GliaCoreSDK

@testable import GliaWidgets

class QueuesMonitorTests: XCTestCase {
    private enum Call {
        case listQueues
        case subscribeForQueuesUpdates
        case unsubscribeFromUpdates
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
    func test_fetchAndMonitorQueuesWithQueuesUpdatesWithQueuesList() {
        var envCalls: [Call] = []
        let expectedLogMessage = "Setting up queues. 1 out of 1 queues provided by an integrator match with site queues."
        var receivedLogMessage = ""
        let mockQueueId = "mock_queue_id"
        let expectedObservedQueues = [Queue.mock(id: mockQueueId)]
        let mockQueues = [expectedObservedQueues[0], Queue.mock(id: UUID().uuidString)]
        monitor.environment.logger.infoClosure = { logMessage, _, _, _ in
            receivedLogMessage = logMessage as? String ?? ""
        }
        monitor.environment.listQueues = { completion in
            envCalls.append(.listQueues)
            completion(mockQueues, nil)
        }
        monitor.environment.subscribeForQueuesUpdates = { _, completion in
            envCalls.append(.subscribeForQueuesUpdates)
            completion(.success(expectedObservedQueues[0]))
            return UUID().uuidString
        }

        var receivedQueues: [Queue]?
        monitor.$state
            .sink { state in
                if case let .updated(queues) = state {
                    receivedQueues = queues
                }
            }
            .store(in: &cancellables)

        monitor.fetchAndMonitorQueues(queuesIds: [mockQueueId])

        XCTAssertEqual(receivedQueues, expectedObservedQueues)
        XCTAssertEqual(envCalls, [.listQueues, .subscribeForQueuesUpdates])
        XCTAssertEqual(receivedLogMessage, expectedLogMessage)
    }

    func test_fetchAndMonitorQueuesWithWrongQueueIdsReturnsUpdatesWithDefaultQueue() {
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
        monitor.environment.listQueues = { completion in
            envCalls.append(.listQueues)
            completion(mockQueues, nil)
        }
        monitor.environment.subscribeForQueuesUpdates = { _, completion in
            envCalls.append(.subscribeForQueuesUpdates)
            completion(.success(mockedQueue))
            return UUID().uuidString
        }

        var receivedQueues: [Queue]?
        monitor.$state
            .sink { state in
                if case let .updated(queues) = state {
                    receivedQueues = queues
                }
            }
            .store(in: &cancellables)

        monitor.fetchAndMonitorQueues(queuesIds: ["1"])

        XCTAssertEqual(receivedQueues, expectedObservedQueues)
        XCTAssertEqual(envCalls, [.listQueues, .subscribeForQueuesUpdates])
        XCTAssertEqual(expectedLogMessages, receivedLogMessage)
    }

    func test_fetchAndMonitorQueuesListQueuesReturnsError() {
        var envCalls: [Call] = []
        let expectedErrorLog = "Setting up queues. Failed to get site queues: mock"
        var receivedErrorLog = ""
        let expectedError = CoreSdkClient.SalemoveError.mock()
        monitor.environment.logger.errorClosure = { logMessage, _, _, _ in
            receivedErrorLog = logMessage as? String ?? ""
        }
        monitor.environment.listQueues = { completion in
            envCalls.append(.listQueues)
            completion(nil, expectedError)
        }
        monitor.environment.subscribeForQueuesUpdates = { _, completion in
            envCalls.append(.subscribeForQueuesUpdates)
            return UUID().uuidString
        }

        var receivedError: CoreSdkClient.SalemoveError?
        monitor.$state
            .sink { state in
                if case let .failed(error as CoreSdkClient.SalemoveError) = state {
                    receivedError = error
                }
            }
            .store(in: &cancellables)

        monitor.fetchAndMonitorQueues(queuesIds: ["1"])

        XCTAssertEqual(receivedError, expectedError)
        XCTAssertEqual(envCalls, [.listQueues])
        XCTAssertEqual(expectedErrorLog, receivedErrorLog)
    }

    func test_fetchAndMonitorQueuesWithQueuesAndReceiveUpdatedQueueSuccess() {
        var envCalls: [Call] = []

        let mockQueueId = "mock_queue_id"
        let expectedObservedQueue = Queue.mock(id: mockQueueId, status: .open)
        let expectedUpdatedQueue = Queue.mock(id: mockQueueId, status: .open)
        let mockQueues = [expectedObservedQueue, Queue.mock(id: UUID().uuidString)]

        monitor.environment.listQueues = { completion in
            envCalls.append(.listQueues)
            completion(mockQueues, nil)
        }
        monitor.environment.subscribeForQueuesUpdates = { _, completion in
            envCalls.append(.subscribeForQueuesUpdates)
            completion(.success(expectedUpdatedQueue))
            return UUID().uuidString
        }

        var receivedQueues: [Queue]?
        var receivedUpdatedQueue: Queue?
        monitor.$state
            // Drop initial .idle and .updated with listed queues state update
            .dropFirst(2)
            .sink { state in
                if case let .updated(queues) = state {
                    receivedQueues = queues
                    receivedUpdatedQueue = queues[0]
                }
            }
            .store(in: &cancellables)

        monitor.fetchAndMonitorQueues(queuesIds: [mockQueueId])

        XCTAssertEqual(receivedQueues, [expectedUpdatedQueue])
        XCTAssertEqual(receivedUpdatedQueue?.state.status, .open)
        XCTAssertEqual(envCalls, [.listQueues, .subscribeForQueuesUpdates])
    }

    func test_fetchAndMonitorQueuesWithQueuesStopsPreviousMonitoring() {
        var envCalls: [Call] = []

        let mockQueueId = "mock_queue_id"
        let expectedObservedQueue = Queue.mock(id: mockQueueId, status: .open)
        let expectedUpdatedQueue = Queue.mock(id: mockQueueId, status: .open)
        let mockQueues = [expectedObservedQueue, Queue.mock(id: UUID().uuidString)]

        monitor.environment.listQueues = { completion in
            envCalls.append(.listQueues)
            completion(mockQueues, nil)
        }
        monitor.environment.subscribeForQueuesUpdates = { _, completion in
            envCalls.append(.subscribeForQueuesUpdates)
            completion(.success(expectedUpdatedQueue))
            return UUID().uuidString
        }
        
        monitor.environment.unsubscribeFromUpdates = { queueCallbackId, error in
            envCalls.append(.unsubscribeFromUpdates)
        }

        var receivedQueues: [Queue]?
        var receivedUpdatedQueue: Queue?
        monitor.$state
            // Drop initial .idle and .updated with listed queues state update
            .dropFirst(2)
            .sink { state in
                if case let .updated(queues) = state {
                    receivedQueues = queues
                    receivedUpdatedQueue = queues[0]
                }
            }
            .store(in: &cancellables)

        monitor.fetchAndMonitorQueues(queuesIds: [mockQueueId])
        monitor.fetchAndMonitorQueues(queuesIds: [mockQueueId])
        addDelay()
        XCTAssertEqual(receivedQueues, [expectedUpdatedQueue])
        XCTAssertEqual(receivedUpdatedQueue?.state.status, .open)
        XCTAssertEqual(
            envCalls,
            [.listQueues, .subscribeForQueuesUpdates, .unsubscribeFromUpdates, .listQueues, .subscribeForQueuesUpdates]
        )
    }
    
    func test_fetchAndMonitorQueuesWithQueuesStopsPreviousMonitoringFailed() {
        var envCalls: [Call] = []

        let mockQueueId = "mock_queue_id"
        let expectedObservedQueue = Queue.mock(id: mockQueueId, status: .closed)
        let expectedUpdatedQueue = Queue.mock(id: mockQueueId, status: .open)
        let mockQueues = [expectedObservedQueue, Queue.mock(id: UUID().uuidString)]

        monitor.environment.listQueues = { completion in
            envCalls.append(.listQueues)
            completion(mockQueues, nil)
        }
        monitor.environment.subscribeForQueuesUpdates = { _, completion in
            envCalls.append(.subscribeForQueuesUpdates)
            completion(.success(expectedUpdatedQueue))
            return UUID().uuidString
        }
        
        monitor.environment.unsubscribeFromUpdates = { queueCallbackId, error in
            envCalls.append(.unsubscribeFromUpdates)
            error(CoreSdkClient.SalemoveError.mock())
        }

        var receivedQueues: [Queue]?
        var receivedUpdatedQueue: Queue?
        monitor.$state
            // Drop initial .idle and .updated with listed queues state update
            .dropFirst(2)
            .sink { state in
                if case let .updated(queues) = state {
                    receivedQueues = queues
                    receivedUpdatedQueue = queues[0]
                }
            }
            .store(in: &cancellables)

        monitor.fetchAndMonitorQueues(queuesIds: [mockQueueId])
        monitor.fetchAndMonitorQueues(queuesIds: [mockQueueId])

        XCTAssertEqual(receivedQueues, [expectedUpdatedQueue])
        XCTAssertEqual(receivedUpdatedQueue?.state.status, .open)
        XCTAssertEqual(
            envCalls,
            [.listQueues, .subscribeForQueuesUpdates, .unsubscribeFromUpdates, .listQueues, .subscribeForQueuesUpdates]
        )
    }

    func test_fetchAndMonitorQueuesWithQueuesAndReceiveUpdatedQueueError() {
        var envCalls: [Call] = []

        let expectedError = CoreSdkClient.SalemoveError.mock()
        let mockQueues = [Queue.mock()]

        monitor.environment.listQueues = { completion in
            envCalls.append(.listQueues)
            completion(mockQueues, nil)
        }
        monitor.environment.subscribeForQueuesUpdates = { _, completion in
            envCalls.append(.subscribeForQueuesUpdates)
            completion(.failure(expectedError))
            return nil
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

        monitor.fetchAndMonitorQueues(queuesIds: [UUID().uuidString])

        XCTAssertEqual(receivedError, expectedError)
        XCTAssertEqual(envCalls, [.listQueues, .subscribeForQueuesUpdates])
    }

    // MARK: Stop monitoring
    func test_stopMonitoringReturnError() {
        var envCalls: [Call] = []

        let expectedError = CoreSdkClient.SalemoveError.mock()

        monitor.environment.listQueues = { completion in
            envCalls.append(.listQueues)
            completion([], nil)
        }
        monitor.environment.subscribeForQueuesUpdates = { _, completion in
            envCalls.append(.subscribeForQueuesUpdates)
            completion(.success(.mock()))
            return UUID().uuidString
        }
        monitor.environment.unsubscribeFromUpdates = { subscriptionId, completion in
            envCalls.append(.unsubscribeFromUpdates)
            completion(expectedError)
        }

        monitor.fetchAndMonitorQueues(queuesIds: ["1"])

        var receivedError: CoreSdkClient.SalemoveError?
        monitor.$state
            .dropFirst()
            .sink { state in
                if case .failed(let error as CoreSdkClient.SalemoveError) = state {
                    receivedError = error
                }
            }
            .store(in: &cancellables)

        monitor.stopMonitoring()

        XCTAssertEqual(receivedError, expectedError)
        XCTAssertEqual(envCalls, [.listQueues, .subscribeForQueuesUpdates, .unsubscribeFromUpdates])
    }

    func test_stopMonitoringSuccess() {
        var envCalls: [Call] = []

        monitor.environment.listQueues = { completion in
            envCalls.append(.listQueues)
            completion([], nil)
        }
        monitor.environment.subscribeForQueuesUpdates = { _, completion in
            envCalls.append(.subscribeForQueuesUpdates)
            completion(.success(.mock()))
            return UUID().uuidString
        }
        monitor.environment.unsubscribeFromUpdates = { subscriptionId, completion in
            envCalls.append(.unsubscribeFromUpdates)
            completion(.mock())
        }

        monitor.fetchAndMonitorQueues(queuesIds: ["1"])

        monitor.stopMonitoring()

        XCTAssertEqual(envCalls, [.listQueues, .subscribeForQueuesUpdates, .unsubscribeFromUpdates])
    }

    func test_receiveOlderQueue_doesNotReplaceExistingQueue() {
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

        monitor.environment.listQueues = { completion in
            envCalls.append(.listQueues)
            completion([existingQueue], nil)
        }
        monitor.environment.subscribeForQueuesUpdates = { _, completion in
            envCalls.append(.subscribeForQueuesUpdates)
            completion(.success(olderQueue))
            return UUID().uuidString
        }
        var receivedQueues: [Queue]?
        monitor.$state
            // Drop initial .idle and then .updated after fetching
            .dropFirst(2)
            .sink { state in
                if case let .updated(queues) = state {
                    receivedQueues = queues
                }
            }
            .store(in: &cancellables)

        monitor.fetchAndMonitorQueues(queuesIds: [mockQueueId])

        XCTAssertEqual(envCalls, [.listQueues, .subscribeForQueuesUpdates])
        XCTAssertEqual(receivedQueues?.count, 1)
        XCTAssertEqual(receivedQueues?.first?.lastUpdated, existingQueue.lastUpdated)
    }

    func test_receiveNewerQueue_updatesExistingQueue() {
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

        monitor.environment.listQueues = { completion in
            envCalls.append(.listQueues)
            completion([oldQueue], nil)
        }
        monitor.environment.subscribeForQueuesUpdates = { _, completion in
            envCalls.append(.subscribeForQueuesUpdates)
            completion(.success(newerQueue))
            return UUID().uuidString
        }

        var receivedQueues: [Queue]?
        monitor.$state
            // Drop initial .idle and then .updated after fetching
            .dropFirst(2)
            .sink { state in
                if case let .updated(queues) = state {
                    receivedQueues = queues
                }
            }
            .store(in: &cancellables)

        monitor.fetchAndMonitorQueues(queuesIds: [mockQueueId])

        XCTAssertEqual(envCalls, [.listQueues, .subscribeForQueuesUpdates])
        XCTAssertEqual(receivedQueues?.count, 1)
        XCTAssertEqual(receivedQueues?.first?.lastUpdated, newerQueue.lastUpdated)
    }

    func test_receiveQueueForUnknownId_appendsQueue() {
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

        monitor.environment.listQueues = { completion in
            envCalls.append(.listQueues)
            completion([knownQueue], nil)
        }
        monitor.environment.subscribeForQueuesUpdates = { _, completion in
            envCalls.append(.subscribeForQueuesUpdates)
            completion(.success(brandNewQueue))
            return UUID().uuidString
        }

        var receivedQueues: [Queue]?
        monitor.$state
            // Drop initial .idle and then .updated after fetching
            .dropFirst(2)
            .sink { state in
                if case let .updated(queues) = state {
                    receivedQueues = queues
                }
            }
            .store(in: &cancellables)

        monitor.fetchAndMonitorQueues(queuesIds: [knownQueueId])

        XCTAssertEqual(envCalls, [.listQueues, .subscribeForQueuesUpdates])
        XCTAssertEqual(receivedQueues?.count, 2)
        XCTAssertTrue(receivedQueues?.contains(where: { $0.id == knownQueueId }) == true)
        XCTAssertTrue(receivedQueues?.contains(where: { $0.id == unknownQueueId }) == true)
    }
}

extension QueuesMonitorTests {
    func addDelay(withDelay: Double = 0.1) {
        let expectation = self.expectation(description: "Wait for view state update")
        expectation.isInverted = true
        wait(for: [expectation], timeout: withDelay)
    }
}
