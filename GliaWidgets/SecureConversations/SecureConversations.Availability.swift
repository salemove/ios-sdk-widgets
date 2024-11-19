import Foundation

extension SecureConversations {
    struct Availability {
        typealias CompletionResult = (Result<Status, CoreSdkClient.SalemoveError>) -> Void

        var environment: Environment

        func checkSecureConversationsAvailability(
            for queueIds: [String],
            completion: @escaping CompletionResult
        ) {
            // if provided queueIds array contains invalid ids,
            // then log a warning message.
            let invalidIds = queueIds.filter { UUID(uuidString: $0) == nil }
            if !invalidIds.isEmpty {
                environment.log.warning("Queue ID array for Secure Messaging contains invalid queue IDs: \(invalidIds).")
            }

            environment.queuesMonitor.fetchAndMonitorQueues(queuesIds: queueIds) { result in
                switch result {
                case .success(let queues):
                    self.checkQueues(fetchedQueues: queues, completion: completion)
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        }

        private func checkQueues(
            fetchedQueues: [CoreSdkClient.Queue],
            completion: (Result<Status, CoreSdkClient.SalemoveError>) -> Void
        ) {
            guard environment.isAuthenticated() else {
                environment.log.warning("Secure Messaging is unavailable because the visitor is not authenticated.")
                completion(.success(.unavailable(.unauthenticated)))
                return
            }

            let filteredQueues = fetchedQueues.filter(defaultPredicate)

            // Check if matched queues match support `messaging` and
            // have status other than `closed`
            guard !filteredQueues.isEmpty else {
                environment.log.warning("Provided queue IDs do not match with queues that have status other than closed and support messaging.")
                completion(.success(.unavailable(.emptyQueue)))
                return
            }
            let queueIds = filteredQueues.map { $0.id }

            environment.log.info("Secure Messaging is available in queues with IDs: \(queueIds).")
            completion(.success(.available(queueIds: queueIds)))
        }

        private var defaultPredicate: (CoreSdkClient.Queue) -> Bool {
            {
                $0.state.status != .closed &&
                $0.state.media.contains(CoreSdkClient.MediaType.messaging)
            }
        }
    }
}

extension SecureConversations.Availability {
    struct Environment {
        var listQueues: CoreSdkClient.ListQueues
        var isAuthenticated: () -> Bool
        var log: CoreSdkClient.Logger
        var queuesMonitor: QueuesMonitor
    }
}

extension SecureConversations.Availability {
    enum Status: Equatable {
        case available(queueIds: [String] = [])
        case unavailable(UnavailabilityReason)

        static func == (lhs: Status, rhs: Status) -> Bool {
            switch (lhs, rhs) {
            case (.available, .available):
                return true
            case let (.unavailable(lhsReason), .unavailable(rhsReason)):
                return lhsReason == rhsReason
            default:
                return false
            }
        }
    }
}

extension SecureConversations.Availability.Status {
    enum UnavailabilityReason: Equatable {
        case emptyQueue
        case unauthenticated
    }
}

extension SecureConversations.Availability.Environment {
    static func create(with environment: ChatCoordinator.Environment) -> Self {
        .init(
            listQueues: environment.listQueues,
            isAuthenticated: environment.isAuthenticated,
            log: environment.log,
            queuesMonitor: environment.queuesMonitor
        )
    }

    static func create(with environment: SecureConversations.Coordinator.Environment) -> Self {
        .init(
            listQueues: environment.listQueues,
            isAuthenticated: environment.isAuthenticated,
            log: environment.log,
            queuesMonitor: environment.queuesMonitor
        )
    }
}

#if DEBUG
extension SecureConversations.Availability {
    static func mock(
        environment: Environment = .mock()
    ) -> SecureConversations.Availability {
        .init(environment: environment)
    }
}

extension SecureConversations.Availability.Environment {
    static func mock(
        listQueues: @escaping CoreSdkClient.ListQueues = { _ in },
        isAuthenticated: @escaping () -> Bool = { false },
        log: CoreSdkClient.Logger = .mock,
        queuesMonitor: QueuesMonitor = .mock()
    ) -> Self {
        .init(
            listQueues: listQueues,
            isAuthenticated: isAuthenticated,
            log: log,
            queuesMonitor: queuesMonitor
        )
    }
}
#endif
