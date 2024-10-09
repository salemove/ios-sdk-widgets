import Foundation
import GliaCoreSDK
import Combine

class QueuesMonitor {
    enum State {
        case idle
        case updated([Queue])
        case failed(Error)
    }

    @Published private(set) var state: State = .idle

    private let environment: Environment
    private var subscriptionId: String?
    private var queues: [Queue] = []

    init(environment: Environment) {
        self.environment = environment

        startMonitoring()
    }

    func startMonitoring() {
        environment.sdkClient.listQueues { [weak self] queues, error in
            guard let self else {
                return
            }
            if let error {
                self.state = .failed(error)
                return
            }

            if let queues {
                self.queues = queues
                self.state = .updated(queues)
                self.observeQueuesUpdates(queues)
                return
            }
        }
    }

    func stopMonitoring() {
        if let subscriptionId {
            environment.sdkClient.unsubscribeFromUpdates(subscriptionId) { [weak self] error in
                self?.state = .failed(error)
            }
        }
    }
}

private extension QueuesMonitor {
    func updateQueue(_ queue: Queue) {
        guard let indexToChange = self.queues.firstIndex(where: { $0.id == queue.id }) else {
            self.queues.append(queue)
            return
        }
        self.queues[indexToChange] = queue
    }

    func observeQueuesUpdates(_ queues: [Queue]) {
        let queuesIds = queues.map { $0.id }
        subscriptionId = environment.sdkClient.subscribeForQueuesUpdates(queuesIds) { [weak self] result in
            guard let self else {
                return
            }
            switch result {
            case .success(let queue):
                self.updateQueue(queue)
                self.state = .updated(self.queues)
                return
            case .failure(let error):
                self.state = .failed(error)
                return
            }
        }
    }
}
