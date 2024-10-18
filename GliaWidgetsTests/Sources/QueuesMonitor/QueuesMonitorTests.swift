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

    // MARK: Start monitoring
    func test_startMonitoringWithQueuesUpdatesWithQueuesList() {
        var envCalls: [Call] = []

        let mockQueueId = UUID().uuidString
        let expectedObservedQueues = [Queue.mock(id: mockQueueId)]
        let mockQueues = [expectedObservedQueues[0], Queue.mock(id: UUID().uuidString)]

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

        monitor.startMonitoring(queuesIds: [mockQueueId])

        XCTAssertEqual(receivedQueues, expectedObservedQueues)
        XCTAssertEqual(envCalls, [.listQueues, .subscribeForQueuesUpdates])
    }

    func test_startMonitoringWithWrongQueueIdsReturnsUpdatesWithDefaultQueue() {
        var envCalls: [Call] = []

        let expectedObservedQueues = [Queue.mock(isDefault: true)]
        let mockQueues = [expectedObservedQueues[0], Queue.mock()]

        monitor.environment.listQueues = { completion in
            envCalls.append(.listQueues)
            completion(mockQueues, nil)
        }
        monitor.environment.subscribeForQueuesUpdates = { _, completion in
            envCalls.append(.subscribeForQueuesUpdates)
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

        monitor.startMonitoring(queuesIds: ["1"])

        XCTAssertEqual(receivedQueues, expectedObservedQueues)
        XCTAssertEqual(envCalls, [.listQueues, .subscribeForQueuesUpdates])
    }

    func test_startMonitoringListQueuesReturnsError() {
        var envCalls: [Call] = []

        let expectedError = CoreSdkClient.SalemoveError.mock()

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

        monitor.startMonitoring(queuesIds: ["1"])

        XCTAssertEqual(receivedError, expectedError)
        XCTAssertEqual(envCalls, [.listQueues])
    }

    func test_startMonitoringWithQueuesAndReceiveUpdatedQueueSuccess() {
        var envCalls: [Call] = []

        let mockQueueId = UUID().uuidString
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

        var receivedQueues: [Queue]?
        var receivedUpdatedQueue: Queue?
        monitor.$state
            // Drop initial .idle and .updated with listed queues state update
            .dropFirst(2)
            .sink { state in
                print(state)
                if case let .updated(queues) = state {
                    receivedQueues = queues
                    receivedUpdatedQueue = queues[0]
                }
            }
            .store(in: &cancellables)

        monitor.startMonitoring(queuesIds: [mockQueueId])

        XCTAssertEqual(receivedQueues, [expectedUpdatedQueue])
        XCTAssertEqual(receivedUpdatedQueue?.state.status, .open)
        XCTAssertEqual(envCalls, [.listQueues, .subscribeForQueuesUpdates])
    }

    func test_startMonitoringWithQueuesAndReceiveUpdatedQueueError() {
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
                print(state)
                if case let .failed(error as CoreSdkClient.SalemoveError) = state {
                    receivedError = error
                }
            }
            .store(in: &cancellables)

        monitor.startMonitoring(queuesIds: [UUID().uuidString])

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

        monitor.startMonitoring(queuesIds: ["1"])

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

        monitor.startMonitoring(queuesIds: ["1"])

        monitor.stopMonitoring()

        XCTAssertEqual(envCalls, [.listQueues, .subscribeForQueuesUpdates, .unsubscribeFromUpdates])
    }
}
