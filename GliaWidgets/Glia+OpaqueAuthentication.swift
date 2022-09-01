extension Glia {
    /// Entry point for Visitor authentication.
    public struct Authentication {
        typealias Callback = (Result<Void, Error>) -> Void
        typealias GetVisitor = () -> Void

        var authenticateWithIdToken: (_ idToken: IdToken, _ callback: @escaping Callback) -> Void
        var deauthenticateWithCallback: (@escaping Callback) -> Void
        var isAuthenticatedClosure: () -> Bool
    }
}

extension Glia.Authentication {
    /// Behavior for authentication and deauthentication.
    public enum Behavior {
        /// Restrict authentication and deauthentication during ongoing engagement.
        case forbiddenDuringEngagement
    }
}

extension Glia.Authentication.Behavior {
    init(with behavior: CoreSdkClient.AuthenticationBehavior) {
        switch behavior {
        case .forbiddenDuringEngagement:
            self = .forbiddenDuringEngagement
        @unknown default:
            self = .forbiddenDuringEngagement
        }
    }

    func toCoreSdk() -> CoreSdkClient.AuthenticationBehavior {
        switch self {
        case .forbiddenDuringEngagement:
            return .forbiddenDuringEngagement
        }
    }
}

extension Glia {
    public func authentication(with behavior: Glia.Authentication.Behavior) throws -> Authentication {
        let auth = try environment.coreSdk.authentication(behavior.toCoreSdk())

        // Reset navigation and UI back to initial state,
        // effectively removing bubble view (if there was one).
        let cleanup = { [weak self] in
            self?.rootCoordinator?.popCoordinator()
            self?.rootCoordinator?.end()
            self?.rootCoordinator = nil
        }

        return .init(
            authenticateWithIdToken: { [weak self, environment] idToken, callback in
                auth.authenticate(with: .init(rawValue: idToken)) { [weak self, environment] result in
                    switch result {
                    case .success:
                        // Cleanup navigation and views.
                        cleanup()
                        // Make sure that authenticated visitor starts
                        // with clean history.
                        environment.authenticatedChatStorage.clear()
                        // Change storage state for messages to be stored in memory.
                        self?.chatStorageState = .authenticated(environment.authenticatedChatStorage)

                    case .failure:
                        break
                    }

                    callback(result.mapError(Glia.Authentication.Error.init) )
                }
            },
            deauthenticateWithCallback: { [weak self, environment] callback in
                auth.deauthenticate { [weak self, environment] result in
                    switch result {
                    case .success:
                        // Cleanup navigation and views.
                        cleanup()
                        // Clear history for authenticated visitor after deauthentication.
                        environment.authenticatedChatStorage.clear()
                        // Change storage state for messages to be stored in database.
                        self?.chatStorageState = .unauthenticated(environment.chatStorage)
                    case .failure:
                        break
                    }

                    callback(result.mapError(Glia.Authentication.Error.init))
                }
            },
            isAuthenticatedClosure: {
                auth.isAuthenticated
            }
        )
    }
}

extension Glia.Authentication {
    /// JWT token represented by `String`.
   public typealias IdToken = String

    /// Authenticate visitor.
    /// - Parameters:
    /// - Parameter idToken: JWT token for visitor authentication.
    /// - Parameter completion: Completion handler.
    public func authenticate(
        with idToken: IdToken,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        self.authenticateWithIdToken(
            idToken,
            completion
        )
    }

    /// Deauthenticate Visitor.
    /// - Parameter completion: Completion handler.
    public func deauthenticate(completion: @escaping (Result<Void, Error>) -> Void) {
        self.deauthenticateWithCallback(completion)
    }

    /// Initialize placeholder instance.
    /// Useful during unit testing.
    public var isAuthenticated: Bool {
        self.isAuthenticatedClosure()
    }
}

extension Glia.Authentication {
    /// Authentication error.
    public struct Error: Swift.Error {
        /// Reason of error.
        public var reason: String
    }
}

extension Glia.Authentication.Error {
    init(error: CoreSdkClient.SalemoveError) {
        self.reason = error.reason
    }
}
