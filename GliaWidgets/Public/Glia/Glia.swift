import SalemoveSDK
import UIKit

/// Engagement media type.
public enum EngagementKind: Equatable {
    /// No engagement
    case none
    /// Chat
    case chat
    /// Audio call
    case audioCall
    /// Video call
    case videoCall
    /// Secure conversations
    case messaging(SecureConversations.InitialScreen = .welcome)
}

extension SecureConversations {
    /// The initial screen seen by a visitor when starting a secure conversation.
    public enum InitialScreen: Equatable {
        /// Shows a screen that has welcome text, and allows to send messages and
        /// attachments. It also allows navigation to the chat transcript screen.
        case welcome
        /// Shows a screen with the chat transcript, which consists of the message
        /// history of the currently authenticated visitor. Also allows sending
        /// messages and attachments.
        case chatTranscript
    }
}

/// An event providing engagement state information.
public enum GliaEvent: Equatable {
    /// Session was started
    case started
    /// Engagement media type changed
    case engagementChanged(EngagementKind)
    /// Session has ended
    case ended
    /// Engagement window was minimized
    case minimized
    /// Engagement window was maximized
    case maximized
}

/// Used to provide `UIWindowScene` to the framework.
public protocol SceneProvider: AnyObject {
    @available(iOS 13.0, *)
    func windowScene() -> UIWindowScene?
}

/// Glia's engagement interface.
public class Glia {
    /// A singleton to access the Glia's interface.
    public static let sharedInstance = Glia(environment: .live)
    /// Current engagement media type.
    public var engagement: EngagementKind { return rootCoordinator?.engagementKind ?? .none }
    /// Used to monitor engagement state changes.
    public var onEvent: ((GliaEvent) -> Void)?

    public lazy var callVisualizer = CallVisualizer(
        environment: .init(
            data: environment.data,
            uuid: environment.uuid,
            gcd: environment.gcd,
            imageViewCache: environment.imageViewCache,
            timerProviding: environment.timerProviding,
            uiApplication: environment.uiApplication,
            requestVisitorCode: environment.coreSdk.requestVisitorCode,
            interactorProviding: { [weak self] in self?.interactor },
            callVisualizerPresenter: environment.callVisualizerPresenter,
            bundleManaging: environment.bundleManaging,
            screenShareHandler: environment.screenShareHandler,
            audioSession: environment.audioSession,
            date: environment.date,
            engagedOperator: { [weak self] in
                self?.environment.coreSdk.getCurrentEngagement()?.engagedOperator
            }
        )
    )
    var rootCoordinator: EngagementCoordinator?
    var interactor: Interactor?
    var environment: Environment
    var messageRenderer: MessageRenderer?
    var uiConfig: RemoteConfiguration?
    var assetsBuilder: RemoteConfiguration.AssetsBuilder = .standard

    init(environment: Environment) {
        self.environment = environment
    }

    /// Setup SDK using specific engagement configuration without starting the engagement.
    /// - Parameters:
    ///   - configuration: Engagement configuration.
    ///   - queueId: Queue identifier.
    ///   - visitorContext: Visitor context.
    ///   - uiConfig: Remote UI configuration.
    ///   - assetsBuilder: Provides assets for remote configuration.
    ///   - completion: Optional completion handler that will be fired once configuration is complete.
    ///   Passing  `nil` will defer configuration. Passing closure will start configuration immediately.
    public func configure(
        with configuration: Configuration,
        queueId: String,
        visitorContext: VisitorContext?,
        uiConfig: RemoteConfiguration? = nil,
        assetsBuilder: RemoteConfiguration.AssetsBuilder = .standard,
        completion: (() -> Void)? = nil
    ) throws {
        self.uiConfig = uiConfig
        self.assetsBuilder = assetsBuilder

        let sdkConfiguration = try GliaCore.Configuration(
            siteId: configuration.site,
            region: configuration.environment.region,
            authorizingMethod: configuration.authorizationMethod.coreAuthorizationMethod,
            pushNotifications: configuration.pushNotifications.coreSdk
        )
        let createdInteractor = Interactor(
            with: sdkConfiguration,
            queueID: queueId,
            visitorContext: visitorContext,
            environment: .init(coreSdk: environment.coreSdk, gcd: environment.gcd)
        )

        interactor = createdInteractor

        if let callback = completion {
            createdInteractor.withConfiguration { [weak createdInteractor] in
                guard let interactor = createdInteractor else { return }
                    interactor.state = GliaCore.sharedInstance
                        .getCurrentEngagement()?.engagedOperator
                        .map(InteractorState.engaged) ?? interactor.state
                    callback()
            }
        }

        startObservingInteractorEvents()
    }

    /// Maximizes engagement view if ongoing engagment exists.
    /// Throws error if ongoing engagement not exist.
    /// Use this function for resuming engagement view If bubble is hidden programmatically and you need to
    /// present engagement view.
    public func resume() throws {
        guard engagement != .none else { throw GliaError.engagementNotExist }
        rootCoordinator?.maximize()
    }

    /// This custom message renderer used for rendering AI custom cards.
    /// Glia Widgets contains implementation for HTML based custom cards. See MessegeRenderer.webRenderer
    ///
    /// - Parameter messageRenderer: Custom message renderer.
    ///
    public func setChatMessageRenderer(messageRenderer: MessageRenderer) {
        self.messageRenderer = messageRenderer
    }

    /// Clear visitor session
    public func clearVisitorSession() {
        environment.coreSdk.clearSession()
    }

    /// Fetch current Visitor's information.
    ///
    /// The information provided by this endpoint is available to all the Operators observing or interacting with the
    /// Visitor. This means that this endpoint can be used to provide additional context about the Visitor to the
    /// Operators.
    ///
    /// - Parameters:
    ///   - completion: A callback that will return the update result or `SalemoveError`
    ///
    /// If the request is unsuccessful for any reason then the completion will have an Error.
    /// The Error may have one of the following causes:
    ///
    /// - `SalemoveSDK.GeneralError.internalError`
    /// - `SalemoveSDK.GeneralError.networkError`
    /// - `SalemoveSDK.ConfigurationError.invalidSite`
    /// - `SalemoveSDK.ConfigurationError.invalidEnvironment`
    /// - `SalemoveSDK.ConfigurationError.invalidAppToken`
    /// - `SalemoveSDK.ConfigurationError.invalidApiToken`
    /// - `GliaError.sdkIsNotConfigured`
    ///
    /// - Important: Note, that in case of engagement has not been started yet, `configure(with:queueID:visitorContext:)` must be called initially prior to this method,
    /// because `GliaError.sdkIsNotConfigured` will occur otherwise.
    ///
    public func fetchVisitorInfo(completion: @escaping (Result<GliaCore.VisitorInfo, Error>) -> Void) {
        guard interactor != nil else {
            completion(.failure(GliaError.sdkIsNotConfigured))
            return
        }
        environment.coreSdk.fetchVisitorInfo(completion)
    }

    /// Update current Visitor's information.
    ///
    /// The information provided by this endpoint is available to all the Operators observing or interacting with the
    /// Visitor. This means that this endpoint can be used to provide additional context about the Visitor to the
    /// Operators.
    ///
    /// In a similar manner custom attributes can be also be used to provide additional context. For example, if your
    /// site separates paying users from free users, then setting a custom attribute of 'user_type' with a value of
    /// either 'free' or 'paying' depending on the Visitor's account can help Operators prioritize different Visitors.
    ///
    /// - Parameters:
    ///   - info: The information for updating Visitor
    ///   - completion: A callback that will return the update result or `SalemoveError`
    ///
    /// If the request is unsuccessful for any reason then the completion will have an Error.
    /// The Error may have one of the following causes:
    ///
    /// - `SalemoveSDK.GeneralError.internalError`
    /// - `SalemoveSDK.GeneralError.networkError`
    /// - `SalemoveSDK.ConfigurationError.invalidSite`
    /// - `SalemoveSDK.ConfigurationError.invalidEnvironment`
    /// - `SalemoveSDK.ConfigurationError.invalidAppToken`
    /// - `SalemoveSDK.ConfigurationError.invalidApiToken`
    /// - `GliaError.sdkIsNotConfigured`
    ///
    /// - Important: Note, that in case of engagement has not been started yet, `configure(with:queueID:visitorContext:)` must be called initially prior to this method,
    /// because `GliaError.sdkIsNotConfigured` will occur otherwise.
    ///
    public func updateVisitorInfo(
        _ info: VisitorInfoUpdate,
        completion: @escaping (Result<Bool, Error>) -> Void
    ) {
        guard interactor != nil else {
            completion(.failure(GliaError.sdkIsNotConfigured))
            return
        }
        environment.coreSdk.updateVisitorInfo(info, completion)
    }

    /// Ends active engagement if existing and closes Widgets SDK UI (includes bubble).
    public func endEngagement(_ completion: @escaping (Result<Void, Error>) -> Void) {
        defer {
            onEvent?(.ended)
            rootCoordinator = nil
        }

        guard interactor != nil else {
            completion(.failure(GliaError.sdkIsNotConfigured))
            return
        }

        interactor?.endSession(
            success: { completion(.success(())) },
            failure: { completion(.failure($0)) }
        )
    }

    /// Deprecated, use ``callVisualizer.showVisitorCodeViewController`` instead.
    @available(*, deprecated, message: "Deprecated, use ``CallVisualizer.showVisitorCodeViewController`` instead.")
    public func requestVisitorCode(completion: @escaping (Result<VisitorCode, Swift.Error>) -> Void) {
        _ = environment.coreSdk.requestVisitorCode(completion)
    }
}

// MARK: - Private

private extension Glia {
    func startObservingInteractorEvents() {
        interactor?.addObserver(self) { [weak self] event in
            guard let engagement = self?.environment.coreSdk.getCurrentEngagement(), engagement.source == .callVisualizer else {
                return
            }
            switch event {
            case .screenShareOffer(answer: let answer):
                self?.environment.coreSdk.requestEngagedOperator { operators, _ in
                    self?.callVisualizer.offerScreenShare(
                        from: operators ?? [],
                        configuration: Theme().alertConfiguration.screenShareOffer,
                        accepted: { answer(true) },
                        declined: { answer(false) }
                    )
                }
            case let .upgradeOffer(offer, answer):
                self?.environment.coreSdk.requestEngagedOperator { operators, _ in
                    self?.callVisualizer.offerMediaUpgrade(
                        from: operators ?? [],
                        offer: offer,
                        answer: answer,
                        accepted: {
                            answer(true, nil)
                            self?.callVisualizer.handleAcceptedUpgrade()
                        },
                        declined: { answer(false, nil) }
                    )
                }
            case let .videoStreamAdded(stream):
                self?.callVisualizer.addVideoStream(stream: stream)
            case let .stateChanged(state):
                if state == .ended(.byOperator) {
                    self?.callVisualizer.endSession()
                }
            default:
                break
            }
        }
    }
}
