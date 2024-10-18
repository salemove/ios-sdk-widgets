import Foundation
import GliaCoreSDK
import Combine

final class QueuesMonitor {
    enum State {
        case idle
        case updated([Queue])
        case failed(Error)
    }

    @Published private(set) var state: State = .idle

    /// Declared as internal var for unit tests purposes
    var environment: Environment
    private var subscriptionId: String? {
        _subscriptionId.value
    }
    private var observedQueues: [Queue] {
        _observedQueues.value
    }

    private var _subscriptionId: LockIsolated<String?> = .init(nil)
    private var _observedQueues: LockIsolated<[Queue]> = .init([])

    init(environment: Environment) {
        self.environment = environment
    }

    func startMonitoring(queuesIds: [String]) {
        environment.listQueues { [weak self] queues, error in
            guard let self else {
                return
            }
            if let error {
                self.state = .failed(error)
                return
            }

            if let queues {
                let integratorsQueues = queues.filter { queuesIds.contains($0.id) }

                let observedQueues = integratorsQueues.isEmpty ? queues.filter { $0.isDefault } : integratorsQueues

                self.state = .updated(observedQueues)
                self.observeQueuesUpdates(observedQueues)

                self._observedQueues.setValue(observedQueues)
                return
            }
        }
    }

    func stopMonitoring() {
        if let subscriptionId {
            environment.unsubscribeFromUpdates(subscriptionId) { [weak self] error in
                self?.state = .failed(error)
            }
        }
    }
}

private extension QueuesMonitor {
    func updateQueue(_ queue: Queue) {
        _observedQueues.withValue { queues in
            guard let indexToChange = queues.firstIndex(where: { $0.id == queue.id }) else {
                queues.append(queue)
                return
            }
            queues[indexToChange] = queue
        }
    }

    func observeQueuesUpdates(_ queues: [Queue]) {
        let queuesIds = queues.map { $0.id }
        let subscriptionId = environment.subscribeForQueuesUpdates(queuesIds) { [weak self] result in
            guard let self else {
                return
            }
            switch result {
            case .success(let queue):
                self.updateQueue(queue)
                self.state = .updated(self.observedQueues)
                return
            case .failure(let error):
                self.state = .failed(error)
                return
            }
        }
        _subscriptionId.setValue(subscriptionId)
    }
}
