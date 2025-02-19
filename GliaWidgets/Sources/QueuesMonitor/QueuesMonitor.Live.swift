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

    // Declared as internal var for unit tests purposes
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

    /// Fetches all available site's queues for given queues IDs.
    ///
    /// - Parameters:
    ///   - queuesIds: The queues IDs that will be monitored.
    ///   - fetchedQueuesCompletion: Returns fetched queues result for given `queuesIds`
    ///   if no queues were found among site's queues returns default queues.
    ///
    func fetchQueues(queuesIds: [String], completion: @escaping (Result<[Queue], GliaCoreError>) -> Void) {
        environment.listQueues { [weak self] queues, error in
            guard let self else {
                return
            }
            if let error {
                environment.logger.error("Setting up queues. Failed to get site queues: \(error)")
                self.state = .failed(error)
                completion(.failure(error))
                return
            }

            let observedQueues = evaluateQueues(queuesIds: queuesIds, fetchedQueues: queues)
            state = .updated(observedQueues)
            self._observedQueues.setValue(observedQueues)
            completion(.success(observedQueues))
        }
    }

    /// Fetches all available site's queues and initiates queues monitoring for given queues IDs.
    ///
    /// - Parameters:
    ///   - queuesIds: The queues IDs that will be monitored.
    ///   - fetchedQueuesCompletion: Returns fetched queues result for given `queuesIds`
    ///   if no queues were found among site's queues returns default queues.
    ///
    func fetchAndMonitorQueues(
        queuesIds: [String] = [],
        fetchedQueuesCompletion: ((Result<[Queue], GliaCoreError>) -> Void)? = nil
    ) {
        stopMonitoring()

        fetchQueues(queuesIds: queuesIds) { [weak self] result in
            if case let .success(queues) = result {
                self?.observeQueuesUpdates(queues)
            }
            fetchedQueuesCompletion?(result)
        }
    }

    /// Stops monitoring queues.
    func stopMonitoring() {
        if let subscriptionId {
            environment.unsubscribeFromUpdates(subscriptionId) { [weak self] error in
                self?.state = .failed(error)
            }
        }
    }
}

private extension QueuesMonitor {
    func evaluateQueues(queuesIds: [String], fetchedQueues: [Queue]?) -> [Queue] {
        guard let queues = fetchedQueues, !queues.isEmpty else {
            environment.logger.warning("Setting up queues. Site has no queues.")
            return []
        }
        environment.logger.debug("Setting up queues. Site has \(queues.count) queues.")

        let matchedQueues = queues.filter {
            queuesIds.contains($0.id)
        }
        environment.logger.info(
            "Setting up queues. \(matchedQueues.count) out of \(queuesIds.count) queues provided by an integrator match with site queues."
        )
        guard !matchedQueues.isEmpty else {
            environment.logger.info("Setting up queues. Integrator specified an empty list of queues.")
            // If no passed queueId is matched with fetched queues,
            // then check default queues instead
            let defaultQueues = queues.filter(\.isDefault)
            environment.logger.info("Setting up queues. Using \(defaultQueues.count) default queues.")
            return defaultQueues
        }

        return matchedQueues
    }

    func updateQueue(_ queue: Queue) {
        _observedQueues.withValue { queues in
            guard let indexToChange = queues.firstIndex(where: { $0.id == queue.id }) else {
                queues.append(queue)
                return
            }
            if queue.lastUpdated > queues[indexToChange].lastUpdated {
                queues[indexToChange] = queue
            }
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
