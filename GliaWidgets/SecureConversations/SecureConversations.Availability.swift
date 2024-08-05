import Foundation

extension SecureConversations {
    struct Availability {
        typealias CompletionResult = (Result<Status, CoreSdkClient.SalemoveError>) -> Void

        var environment: Environment

        func checkSecureConversationsAvailability(
            for queueIds: [String],
            completion: @escaping CompletionResult
        ) {
            environment.listQueues { queues, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }

                self.checkQueues(
                    queueIds: queueIds,
                    fetchedQueues: queues,
                    completion: completion
                )
            }
        }

        private func checkQueues(
            queueIds: [String],
            fetchedQueues: [CoreSdkClient.Queue]?,
            completion: (Result<Status, CoreSdkClient.SalemoveError>) -> Void
        ) {
            guard environment.isAuthenticated() else {
                environment.log.warning("Secure Messaging is unavailable because the visitor is not authenticated.")
                completion(.success(.unavailable(.unauthenticated)))
                return
            }

            guard let queues = fetchedQueues else {
                // If no queue fetched from the server,
                // return `.unavailable(.emptyQueue)`
                completion(.success(.unavailable(.emptyQueue)))
                return
            }

            // if provided queueIds array contains invalid ids,
            // then log a warning message.
            let invalidIds = queueIds.filter { UUID(uuidString: $0) == nil }
            if !invalidIds.isEmpty {
                environment.log.warning("Queue ID array for Secure Messaging contains invalid queue IDs: \(invalidIds).")
            }

            let matchedQueues = queues.filter { queueIds.contains($0.id) }

            guard !matchedQueues.isEmpty else {
                // if provided queue ids array is not empty, but ids do not
                // match with any queue, then log a warning message
                if !queueIds.isEmpty {
                    environment.log.warning("Provided queue IDs do not match with any queue.")
                }
                // If no passed queueId is matched with fetched queues,
                // then check default queues instead
                let defaultQueues = queues.filter(\.isDefault)
                // Filter queues supporting `messaging` and have status other than `closed`
                let filteredQueues = defaultQueues.filter(defaultPredicate)

                if filteredQueues.isEmpty {
                    environment.log.warning("No default queues that have status other than closed and support messaging were found.")
                    // if no default queue supports `messaging` and
                    // have status other than `closed`, return `.unavailable(.emptyQueue)`
                    completion(.success(.unavailable(.emptyQueue)))
                    return
                }

                // Otherwise, return default queue ids
                let defaultQueueIds = defaultQueues.map(\.id)
                environment.log.info("Secure Messaging is available using queues that are set as **Default**.")
                completion(.success(.available(queueIds: defaultQueueIds)))
                return
            }

            let filteredQueues = matchedQueues.filter(defaultPredicate)

            // Check if matched queues match support `messaging` and
            // have status other than `closed`
            guard !filteredQueues.isEmpty else {
                environment.log.warning("Provided queue IDs do not match with queues that have status other than closed and support messaging.")
                completion(.success(.unavailable(.emptyQueue)))
                return
            }

            environment.log.info("Secure Messaging is available in queues with IDs: \(queueIds).")
            completion(.success(.available(queueIds: queueIds)))
        }

        private var defaultPredicate: (CoreSdkClient.Queue) -> Bool {
          return {
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
            log: environment.log
        )
    }

    static func create(with environment: SecureConversations.Coordinator.Environment) -> Self {
        .init(
            listQueues: environment.listQueues,
            isAuthenticated: environment.isAuthenticated,
            log: environment.log
        )
    }
}
