import Foundation

extension Glia {
    /// Entry point for Visitor authentication.
    public struct Authentication {
        typealias Callback = (Result<Void, Error>) -> Void
        typealias RefreshCompletion = (Result<Void, Error>) -> Void
        typealias GetVisitor = () -> Void

        var authenticateWithIdToken: (_ idToken: IdToken, _ accessToken: AccessToken?, _ callback: @escaping Callback) -> Void
        var deauthenticateWithCallback: (@escaping Callback) -> Void
        var isAuthenticatedClosure: () -> Bool
        var refresh: (
            _ idToken: IdToken,
            _ externalAccessToken: AccessToken?,
            _ completion: @escaping RefreshCompletion
        ) -> Void
        var environment: Environment
    }
}

extension Glia.Authentication {
    /// Behavior for authentication and deauthentication.
    public enum Behavior {
        /// Restrict authentication and deauthentication during ongoing engagement.
        case forbiddenDuringEngagement
        /// Allow authentication and deauthentication during ongoing engagement.
        case allowedDuringEngagement
    }
}

extension Glia.Authentication.Behavior {
    init(with behavior: CoreSdkClient.AuthenticationBehavior) {
        switch behavior {
        case .forbiddenDuringEngagement:
            self = .forbiddenDuringEngagement
        case .allowedDuringEngagement:
            self = .allowedDuringEngagement
        @unknown default:
            self = .forbiddenDuringEngagement
        }
    }

    func toCoreSdk() -> CoreSdkClient.AuthenticationBehavior {
        switch self {
        case .forbiddenDuringEngagement:
            return .forbiddenDuringEngagement
        case .allowedDuringEngagement:
            return .allowedDuringEngagement
        }
    }
}

extension Glia {
    /// Initiates authentication with specified behavior, manages UI state reset, 
    /// and handles authentication operations.
    ///
    /// - Parameters:
    ///   - behavior: The behavior defining how authentication should be handled.
    ///
    /// - Throws:
    ///   - `GliaCoreError(reason: "SDK is not configured properly. Make sure it is fully configured and try again.")`
    ///   
    /// - Returns:
    ///   - `Authentication` object configured with authentication operations
    ///
    /// This method prepares the authentication process according to the given behavior, 
    /// ensuring the UI is reset to its initial state upon successful authentication or deauthentication.
    /// It returns an `Authentication` instance which provides methods to authenticate with an ID token
    /// and access token, deauthenticate, and check if currently authenticated. The method also
    /// configures logging environment and cleans up UI and navigation states as necessary.
    ///
    public func authentication(with behavior: Glia.Authentication.Behavior) throws -> Authentication {
        let auth = try environment.coreSdk.authentication(behavior.toCoreSdk())

        return .init(
            authenticateWithIdToken: { [weak self] idToken, accessToken, callback in
                self?.loggerPhase.logger.prefixed(Self.self).info(
                    "Authenticate. Is external access token used: \(accessToken != nil)"
                )

                let interactor = self?.interactor
                let viewFactory = self?.rootCoordinator?.viewFactory
                let sceneProvider = self?.rootCoordinator?.sceneProvider

                let prevEngagementIsNotPresent = self?.environment.coreSdk.getCurrentEngagement() == nil

                // We need to unsubscribe from listening to Interactor events
                // until authentication is finished to avoid
                // calling engagement restoration twice.
                self?.stopObservingInteractorEvents()

                auth.authenticate(
                    with: .init(rawValue: idToken),
                    externalAccessToken: accessToken.map { .init(rawValue: $0) }
                ) { [weak self]  result in
                    // Wait for possible engagement (if there is one)
                    // to get restored along with `rootCoordinator`
                    // and bubble view.
                    self?.environment.gcd.mainQueue.asyncAfterDeadline(.now() + .seconds(1)) {
                        switch result {
                        case .success:
                            // Attempt to restore ongoing engagement after configuration.
                            if let ongoingEngagement = self?.environment.coreSdk.getCurrentEngagement(),
                                let configuration = self?.configuration, prevEngagementIsNotPresent,
                                let interactor {
                                self?.closeRootCoordinator()
                                self?.restoreOngoingEngagement(
                                    configuration: configuration,
                                    currentEngagement: ongoingEngagement,
                                    interactor: interactor,
                                    features: self?.features ?? .all,
                                    maximize: false
                                )
                            } else {
                                // Handle authentication with possibility to restart engagement.
                                self?.restartEngagementIfNeeded(
                                    interactor: interactor,
                                    viewFactory: viewFactory,
                                    sceneProvider: sceneProvider,
                                    features: self?.features
                                )
                            }
                            // We need to subscribe on Interactor events
                            // once authentication if finished.
                            self?.startObservingInteractorEvents()
                        case .failure:
                            break
                        }

                        callback(result.mapError(Glia.Authentication.Error.init) )
                    }
                }
            },
            deauthenticateWithCallback: { [weak self] callback in
                self?.loggerPhase.logger.prefixed(Self.self).info("Unauthenticate")
                auth.deauthenticate { result in
                    switch result {
                    case .success:
                        // Erase interactor state.
                        self?.interactor?.cleanup()
                        // Cleanup navigation and views.
                        self?.closeRootCoordinator()
                    case .failure:
                        break
                    }

                    callback(result.mapError(Glia.Authentication.Error.init))
                }
            },
            isAuthenticatedClosure: {
                auth.isAuthenticated
            },
            refresh: { idToken, accessToken, completion in
                auth.refresh(
                    with: .init(rawValue: idToken),
                    externalAccessToken: accessToken.map { .init(rawValue: $0) }
                ) { result in
                    completion(result.mapError(Glia.Authentication.Error.init))
                }
            },
            environment: .create(with: loggerPhase.logger)
        )
    }

    private func restartEngagementIfNeeded(
        interactor: Interactor?,
        viewFactory: ViewFactory?,
        sceneProvider: SceneProvider?,
        features: Features?
    ) {
        closeRootCoordinator()
        // Restart engagement happens implicitly, however, to create RootCoordinator
        // queueId, engagementKind, etc. are needed.
        // Copy existed interactor, viewFactory, and feature list in case the engagement
        // should be restarted with the same options.
        guard let interactor = interactor,
              let viewFactory = viewFactory,
              let features = features else { return }

        // Waits for while for establishing socket connection, connection to channels, and
        // receive necessary information about engagement.
        environment.gcd.mainQueue.asyncAfterDeadline(.now() + .seconds(2)) { [weak self] in
            if let restartedEngagement = self?.interactor?.currentEngagement, restartedEngagement.restartedFromEngagementId != nil {
                // In case engagement should be restarted, LO ack should not
                // be appeared again.
                interactor.skipLiveObservationConfirmations = true

                self?.startRootCoordinator(
                    with: interactor,
                    viewFactory: viewFactory,
                    sceneProvider: sceneProvider,
                    engagementKind: .init(media: restartedEngagement.mediaStreams),
                    features: features,
                    maximize: false
                )

                self?.rootCoordinator?.gliaViewController?.minimize(animated: false)
            } else {
                self?.closeRootCoordinator()
            }
        }
    }

    private func closeRootCoordinator() {
        rootCoordinator?.popCoordinator()
        rootCoordinator?.end(surveyPresentation: .doNotPresentSurvey)
        rootCoordinator = nil
    }
}

extension Glia.Authentication {
    /// JWT token represented by `String`.
    public typealias IdToken = String

    /// Access token represented by `String`.
    public typealias AccessToken = String

    /// Authenticate visitor.
    ///
    /// - Parameters:
    ///   - idToken: JWT token for visitor authentication.
    ///   - accessToken: Access token for visitor authentication.
    ///   - completion: Completion handler.
    ///
    public func authenticate(
        with idToken: IdToken,
        accessToken: AccessToken?,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        self.authenticateWithIdToken(
            idToken,
            accessToken,
            completion
        )
    }

    /// Deauthenticate Visitor.
    ///
    /// - Parameters:
    ///   - completion: Completion handler.
    ///
    public func deauthenticate(completion: @escaping (Result<Void, Error>) -> Void) {
        self.deauthenticateWithCallback(completion)
    }

    /// Initialize placeholder instance.
    /// Useful during unit testing.
    public var isAuthenticated: Bool {
        self.isAuthenticatedClosure()
    }

    /// Refresh access token
    ///
    /// - Parameters:
    ///   - idToken: ID Token
    ///   - accessToken: External access token
    ///   - completion: Completion handler.
    ///
    public func refresh(
        with idToken: IdToken,
        accessToken: AccessToken?,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        self.refresh(idToken, accessToken, completion)
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
