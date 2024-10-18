import XCTest
import Combine
import GliaCoreSDK

@testable import GliaWidgets

class QueuesMonitorTests: XCTestCase {
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
    func test_startMonitoringWithQueues() {
        let mockQueueId = UUID().uuidString
        let expectedObservedQueues = [Queue.mock(id: mockQueueId)]
        let mockQueues = [expectedObservedQueues[0], Queue.mock(id: UUID().uuidString)]

        monitor.environment.listQueues = { completion in
            completion(mockQueues, nil)
        }

        let expectation = XCTestExpectation(description: "State is updated with queues")

        monitor.$state
            .sink { state in
                if case let .updated(queues) = state {
                    XCTAssertEqual(queues, expectedObservedQueues)
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)

        monitor.startMonitoring(queuesIds: [mockQueueId])

        wait(for: [expectation], timeout: 1.0)
    }

    func test_startMonitoringWithNoQueues() {
        let expectedObservedQueues = [Queue.mock(isDefault: true)]
        let mockQueues = [expectedObservedQueues[0], Queue.mock()]

        monitor.environment.listQueues = { completion in
            completion(mockQueues, nil)
        }

        let expectation = XCTestExpectation(description: "State is updated with default queues if no queue is found")

        monitor.$state
            .sink { state in
                if case let .updated(queues) = state {
                    XCTAssertEqual(queues, expectedObservedQueues)
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)

        monitor.startMonitoring(queuesIds: ["1"])

        wait(for: [expectation], timeout: 1.0)
    }

    func test_startMonitoringError() {
        let expectedError = CoreSdkClient.SalemoveError.mock()

        monitor.environment.listQueues = { completion in
            completion(nil, expectedError)
        }

        let expectation = XCTestExpectation(description: "State is failed with error")

        monitor.$state
            .sink { state in
                if case let .failed(error as CoreSdkClient.SalemoveError) = state {
                    XCTAssertEqual(error, expectedError)
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)

        monitor.startMonitoring(queuesIds: ["1"])

        wait(for: [expectation], timeout: 1.0)
    }

    func test_startMonitoringWithQueuesAndReceiveUpdatedQueueSuccess() {
        let mockQueueId = UUID().uuidString
        let expectedObservedQueue = Queue.mock(id: mockQueueId, status: .closed)
        let expectedUpdatedQueue = Queue.mock(id: mockQueueId, status: .open)
        let mockQueues = [expectedObservedQueue, Queue.mock(id: UUID().uuidString)]

        monitor.environment.listQueues = { completion in
            completion(mockQueues, nil)
        }

        monitor.environment.subscribeForQueuesUpdates = { _, completion in
            completion(.success(expectedUpdatedQueue))
            return UUID().uuidString
        }

        let expectation = XCTestExpectation(description: "State is updated with queues")

        monitor.$state
            // Drop initial .idle and .updated with listed queues state update
            .dropFirst(2)
            .sink { state in
                print(state)
                if case let .updated(queues) = state {
                    XCTAssertEqual(queues, [expectedUpdatedQueue])
                    XCTAssertEqual(queues[0].state.status, .open)
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)

        monitor.startMonitoring(queuesIds: [mockQueueId])

        wait(for: [expectation], timeout: 1.0)
    }

    func test_startMonitoringWithQueuesAndReceiveUpdatedQueueError() {
        let expectedError = CoreSdkClient.SalemoveError.mock()
        let mockQueues = [Queue.mock()]

        monitor.environment.listQueues = { completion in
            completion(mockQueues, nil)
        }

        monitor.environment.subscribeForQueuesUpdates = { _, completion in
            completion(.failure(expectedError))
            return nil
        }

        let expectation = XCTestExpectation(description: "State is updated with queues")

        monitor.$state
            // Drop initial .idle and .updated with listed queues state update
            .dropFirst(2)
            .sink { state in
                print(state)
                if case let .failed(error as CoreSdkClient.SalemoveError) = state {
                    XCTAssertEqual(error, expectedError)
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)

        monitor.startMonitoring(queuesIds: [UUID().uuidString])

        wait(for: [expectation], timeout: 1.0)
    }

    // MARK: Stop
    func test_stopMonitoringError() {
        let expectedError = CoreSdkClient.SalemoveError.mock()

        monitor.environment.unsubscribeFromUpdates = { subscriptionId, completion in
            completion(expectedError)
        }
        monitor.environment.listQueues = { completion in
            completion([], nil)
        }

        monitor.startMonitoring(queuesIds: ["1"])

        let expectation = XCTestExpectation(description: "Check if stopMonitoring changes state to idle")
        monitor.$state
            .dropFirst()
            .sink { state in
                if case .failed(let error as CoreSdkClient.SalemoveError) = state {
                    XCTAssertEqual(error, expectedError)
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)

        monitor.stopMonitoring()

        wait(for: [expectation], timeout: 1.0)
    }
}
