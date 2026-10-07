import Foundation
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
    private var observedQueues: [Queue] {
        _observedQueues.value
    }

    private var queueUpdatesTask: Task<Void, Never>?
    private var monitoringRequestId = UUID()
    private var _observedQueues: LockIsolated<[Queue]> = .init([])

    init(environment: Environment) {
        self.environment = environment
    }

    deinit {
        queueUpdatesTask?.cancel()
    }

    /// Fetches all available site's queues for given queues IDs.
    ///
    /// - Parameters:
    ///   - queuesIds: The queues IDs that will be monitored.
    ///   - fetchedQueuesCompletion: Returns fetched queues result for given `queuesIds`
    ///   if no queues were found among site's queues returns default queues.
    ///
    @MainActor
    func fetchQueues(queuesIds: [String]) async throws -> [Queue] {
        do {
            let queues = try await environment.getQueues()
            let observedQueues = evaluateQueues(queuesIds: queuesIds, fetchedQueues: queues)
            state = .updated(observedQueues)
            self._observedQueues.setValue(observedQueues)
            return observedQueues
        } catch {
            environment.logger.error("Setting up queues. Failed to get site queues: \(error)")
            self.state = .failed(error)
            throw error
        }
    }

    /// Fetches all available site's queues and initiates queues monitoring for given queues IDs.
    ///
    /// - Parameters:
    ///   - queuesIds: The queues IDs that will be monitored.
    ///   - fetchedQueuesCompletion: Returns fetched queues result for given `queuesIds`
    ///   if no queues were found among site's queues returns default queues.
    ///
    @MainActor
    func fetchAndMonitorQueues(queuesIds: [String] = []) async throws -> [Queue] {
        stopMonitoring()
        let requestId = UUID()
        monitoringRequestId = requestId
        let queues = try await fetchQueues(queuesIds: queuesIds)
        // A newer monitoring request was made while queues were being fetched,
        // so that request is responsible for observing updates.
        if monitoringRequestId == requestId {
            observeQueuesUpdates(queues)
        }
        return queues
    }

    /// Stops monitoring queues.
    @MainActor
    func stopMonitoring() {
        queueUpdatesTask?.cancel()
        queueUpdatesTask = nil
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

    @MainActor
    func observeQueuesUpdates(_ queues: [Queue]) {
        stopMonitoring()
        let queuesIds = queues.map { $0.id }
        let updates = environment.queueUpdatesStream(queuesIds)
        queueUpdatesTask = Task { @MainActor [weak self] in
            do {
                for try await queue in updates {
                    guard !Task.isCancelled else { return }
                    guard let self else { return }
                    self.updateQueue(queue)
                    self.state = .updated(self.observedQueues)
                }
            } catch {
                guard !Task.isCancelled, let self else { return }
                self.handleQueueUpdatesFailure(error)
            }
        }
    }

    @MainActor
    func handleQueueUpdatesFailure(_ error: Error) {
        switch error {
        case is CancellationError:
            return
        case let error as CoreSdkClient.GliaCoreError where error.error as? CoreSdkClient.GeneralError == .internalError:
            // Core SDK fails the subscription with an internal error when the socket is not
            // connected yet. Fetched queues stay valid, so this must not surface as a failure.
            environment.logger.warning("Setting up queues. Queue updates are unavailable: \(error.reason)")
        default:
            state = .failed(error)
        }
    }
}
