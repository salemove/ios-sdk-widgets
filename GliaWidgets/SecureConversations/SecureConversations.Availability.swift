import Foundation

extension SecureConversations {
    struct Availability {
        typealias CompletionResult = (Result<Status, CoreSdkClient.SalemoveError>) -> Void
        let environment: Environment

        func checkSecureConversationsAvailability(completion: @escaping CompletionResult) {
            environment.listQueues { queues, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }

                self.checkQueues(queues, completion: completion)
            }
        }

        private func checkQueues(
            _ queues: [CoreSdkClient.Queue]?,
            completion: (Result<Status, CoreSdkClient.SalemoveError>) -> Void
        ) {
            guard environment.isAuthenticated() else {
                completion(.success(.unavailable(.unauthenticated)))
                return
            }

            guard let queues = queues, isSecureConversationsAvailable(in: queues) else {
                completion(.success(.unavailable(.emptyQueue)))
                return
            }

            completion(.success(.available))
        }

        private func isSecureConversationsAvailable(
            in queues: [CoreSdkClient.Queue]
        ) -> Bool {
            let filteredQueues = queues
                .filter {
                    self.environment.queueIds.contains($0.id) &&
                    $0.state.status != .closed &&
                    $0.state.media.contains(CoreSdkClient.MediaType.messaging)
                }

            return !filteredQueues.isEmpty
        }
    }
}

extension SecureConversations.Availability {
    struct Environment {
        let listQueues: CoreSdkClient.ListQueues
        let queueIds: [String]
        let isAuthenticated: () -> Bool
    }
}

extension SecureConversations.Availability {
    enum Status: Equatable {
        case available
        case unavailable(UnavailabilityReason)
    }
}

extension SecureConversations.Availability.Status {
    enum UnavailabilityReason: Equatable {
        case emptyQueue
        case unauthenticated
    }
}
