import GliaCoreSDK
import Combine
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

extension EngagementKind {
    /// This initializer makes instance of `EngagementKind`
    /// to reflect `MediaState` from Core SDK.
    init(media: Engagement.Media) {
        switch (media.audio, media.video) {
        case (_, .some):
            self = .videoCall
        case (.some, .none):
            self = .audioCall
        default:
            self = .chat
        }
    }

    var isMessaging: Bool {
        switch self {
        case .messaging:
            return true
        case .none, .chat, .audioCall, .videoCall:
            return false
        }
    }

    var mediaType: CoreSdkClient.MediaType {
        .init(engagementKind: self)
    }
}

/// State of SDK while restoring engagement after configuration
enum EngagementRestorationState {
    case none
    case restoring
    /// State of SDK when engagement was restored, restarted or there was no engagement after SDK configured
    case restored
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
    func windowScene() -> UIWindowScene?
}

private extension Glia {
    static let maximumUploads = 25
    static let markUnreadMessagesDelaySeconds = 6
}

/// Glia's engagement interface.
public class Glia {
    /// A singleton to access the Glia's interface.
    public static let sharedInstance = Glia(environment: .live)

    /// Current engagement media type.
    public var engagement: EngagementKind { return rootCoordinator?.engagementLaunching.currentKind ?? .none }

    /// Used to monitor engagement state changes.
    public var onEvent: ((GliaEvent) -> Void)?
    @Published var engagementRestorationState: EngagementRestorationState = .none

    var stringProvidingPhase: StringProvidingPhase = .notConfigured

    lazy var maximumUploads: Int = {
        var value = Self.maximumUploads
        /// `MAXIMUM_UPLOADS_PER_MESSAGE` is used in acceptance tests to decrease the time
        /// for uploading maximum number of files in a single message.
        if let stringValue = environment.processInfo.value(for: .maximumUploads) {
            /// Round to 1, because the attachment button doesn't turns to disabled state
            /// if the value is set to 0.
            value = max(Int(stringValue) ?? 1, 1)
        }
        return value
    }()

    lazy var markUnreadMessagesDelay: DispatchQueue.SchedulerTimeType.Stride = .seconds(Self.markUnreadMessagesDelaySeconds)

    public lazy var callVisualizer = CallVisualizer(
        environment: .create(
            with: environment,
            interactorPublisher: $interactor.eraseToAnyPublisher(),
            engagedOperator: { [weak self] in
                self?.environment.coreSdk.getNonTransferredSecureConversationEngagement()?.engagedOperator
            },
            theme: theme,
            assetBuilder: { [weak self] in self?.assetsBuilder ?? .standard },
            onEvent: onEvent,
            loggerPhase: loggerPhase,
            alertManager: alertManager
        )
    )
    var rootCoordinator: EngagementCoordinator?
    @Published var interactor: Interactor?
    var environment: Environment
    var messageRenderer: MessageRenderer? = .webRenderer
    var theme: Theme
    var assetsBuilder: RemoteConfiguration.AssetsBuilder = .standard
    var loggerPhase: LoggerPhase
    var queuesMonitor: QueuesMonitor
    public let pushNotifications: PushNotifications
    var alertManager: AlertManager
    public let liveObservation: LiveObservation
    public let secureConversation: SecureConversations
    public let localeProvider: LocaleProvider
    // We need to store `features` via `configure` method to use it
    // when engagement gets restored for Direct ID authentication flow.
    var features: Features?

    private(set) var configuration: Configuration?
    var cancelBag = Set<AnyCancellable>()

    // Indicates whether at least one of two conditions is correct:
    // - pending secure conversation exists;
    // - unread message count > 0.
    //
    // Currently it's used to know if we have to force a visitor to SecureMessaging screen,
    // once they try to start an engagement with media type other than `messaging`.
    var pendingInteraction: SecureConversations.PendingInteraction?

    init(environment: Environment) {
        self.environment = environment
        self.theme = Theme()

        do {
            let logger = try environment.coreSdk.createLogger(CoreSdkClient.Logger.loggerParameters)
            if environment.conditionalCompilation.isDebug() {
            // In debug mode local and remote logs are turned off.
                try logger.configureLocalLogLevel(.none)
                try logger.configureRemoteLogLevel(.none)
            // In non-debug mode local logs are turned off and remote are on.
            } else {
                try logger.configureLocalLogLevel(.none)
                try logger.configureRemoteLogLevel(.info)
            }
            loggerPhase = .configured(logger)
        } catch {
            environment.print("Unable to configure logger: '\(error)'.")
            self.loggerPhase = .notConfigured(.notConfigured)
        }

        let viewFactory = ViewFactory(
            with: theme,
            messageRenderer: messageRenderer,
            environment: .create(
                with: environment,
                loggerPhase: loggerPhase
            )
        )
        queuesMonitor = .init(environment: .init(
            getQueues: environment.coreSdk.getQueues,
            subscribeForQueuesUpdates: environment.coreSdk.subscribeForQueuesUpdates,
            unsubscribeFromUpdates: environment.coreSdk.unsubscribeFromUpdates,
            logger: loggerPhase.logger
        ))
        alertManager = .init(
            environment: .create(
                with: environment,
                logger: loggerPhase.logger,
                viewFactory: viewFactory
            )
        )
        liveObservation = .init(environment: .create(with: environment))

        pushNotifications = .init(environment: .create(with: environment))

        secureConversation = .init(environment: .create(with: environment))

        localeProvider = .init(locale: environment.coreSdk.localeProvider.getRemoteString)

        environment.coreSdk.pushNotifications.actions.setSecureMessageAction { [weak self] senderQueueId in
            guard let self else { return }
            self.$engagementRestorationState
                .receive(on: environment.combineScheduler.main)
                .first { $0 == .restored }
                .sink { _ in
                    self.loggerPhase.logger.prefixed(Self.self).info(
                        "Chat transcript is opened from Secure Conversation push notification message"
                    )
                    let engagementLauncher = try? self.getEngagementLauncher(queueIds: [senderQueueId].compactMap { $0 })
                    try? engagementLauncher?.startSecureMessaging(initialScreen: .chatTranscript)
                }
                .store(in: &cancelBag)
        }
    }

    /// Setup SDK using specific engagement configuration without starting the engagement.
    /// - Parameters:
    ///   - configuration: Engagement configuration.
    ///   - theme: A custom theme to use with the engagement.
    ///   - uiConfig: Remote UI configuration.
    ///   - assetsBuilder: Provides assets for remote configuration.
    ///   - features: Set of features to be enabled in the SDK.
    ///   - completion: Completion handler that will be fired once configuration is
    ///     complete.
    ///
    /// - Throws:
    ///   - `GliaError.configuringDuringEngagementIsNotAllowed`
    ///   - `ConfigurationError`
    ///
    public func configure(
        with configuration: Configuration,
        theme: Theme = Theme(),
        uiConfig: RemoteConfiguration? = nil,
        assetsBuilder: RemoteConfiguration.AssetsBuilder = .standard,
        features: Features = .all,
        completion: @escaping (Result<Void, Error>) -> Void
    ) throws {
        guard environment.coreSdk.getNonTransferredSecureConversationEngagement() == nil else {
            throw GliaError.configuringDuringEngagementIsNotAllowed
        }

        if configuration.isWhiteLabelApp {
            theme.showsPoweredBy = false
        }

        if let uiConfig {
            theme.apply(configuration: uiConfig, assetsBuilder: assetsBuilder)
        }

        self.theme = theme
        self.assetsBuilder = assetsBuilder
        // We need to store features to be used for restored engagement
        // during Direct ID authenticated flow.
        self.features = features
        // `configuration` should be erased to avoid cases when integrators
        // call `configure` and `startEngagement` asynchronously, and
        // second-time configuration has not been complete, but `startEngagement`
        // is fired and SDK has previous `configuration`.
        self.configuration = nil
        self.engagementRestorationState = .none

        alertManager.overrideTheme(theme)

        self.callVisualizer.delegate = { action in
            switch action {
            case .engagementStarted:
                self.onEvent?(.started)
            case .engagementEnded:
                self.onEvent?(.ended)
            }
        }

        try environment.coreSDKConfigurator.configureWithConfiguration(configuration) { [weak self] result in
            guard let self else { return }
            switch result {
            case .success:
                defer {
                    self.loggerPhase.logger.prefixed(Self.self).info("Initialize Glia Widgets SDK")
                    if uiConfig != nil {
                        self.loggerPhase.logger.remoteLogger?.prefixed(Self.self)
                            .info("Setting Unified UI Config")
                    }
                }
                // Storing `configuration` needs to be done once configuring SDK is complete
                // Otherwise integrator can call `configure` and `startEngagement`
                // asynchronously, without waiting configuration completion.
                self.configuration = configuration

                let interactor = self.setupInteractor(configuration: configuration)
                self.interactor = interactor
                self.callVisualizer.startObservingInteractorEvents()

                let getRemoteString = self.environment.coreSdk.localeProvider.getRemoteString
                self.stringProvidingPhase = .configured(getRemoteString)

                // Configuration completion handler has to be called in any case,
                // at the end of the scope, whether there's ongoing engagement or not.
                defer {
                    // PendingInteraction is essential part of SC flow, so it's not
                    // valid to consider SDK configured if PI is not created.
                    do {
                        pendingInteraction = try .init(environment: .init(
                            client: environment.coreSdk,
                            interactorPublisher: Just(interactor).eraseToAnyPublisher()
                        ))
                        startObservingInteractorEvents()
                        completion(.success(()))
                    } catch let error as SecureConversations.PendingInteraction.Error {
                        switch error {
                        case .subscriptionFailure:
                            completion(.failure(GliaError.internalEventSubscriptionFailure))
                        }
                    } catch {
                        completion(.failure(GliaError.internalError))
                    }
                }

                guard let currentEngagement = self.environment.coreSdk.getNonTransferredSecureConversationEngagement() else { return }

                if currentEngagement.source == .callVisualizer {
                    self.callVisualizer.handleRestoredEngagement()
                } else {
                    self.restoreOngoingEngagement(
                        configuration: configuration,
                        currentEngagement: currentEngagement,
                        interactor: interactor,
                        features: features,
                        maximize: false
                    )
                }
            case .failure(let error):
                typealias ProcessError = CoreSdkClient.ConfigurationProcessError
                var errorForCompletion: GliaError = .internalError

                // To avoid the integrator having to figure out if an error is a `GliaError`
                // or a `ConfigurationProcessError`, the `ConfigurationProcessError` is translated
                // into a `GliaError`.
                if let processError = error as? ProcessError {
                    if processError == .invalidSiteApiKeyCredentials {
                        errorForCompletion = GliaError.invalidSiteApiKeyCredentials
                    } else if processError == .localeRetrieval {
                        errorForCompletion = GliaError.invalidLocale
                    }
                }
                loggerPhase.logger.error("Glia Widgets SDK initialization failed")
                debugPrint("💥 Core SDK configuration is not valid. Unexpected error='\(error)'.")
                completion(.failure(errorForCompletion))
            }
        }
    }

    /// Minimizes engagement view if ongoing engagement exists.
    /// Use this function to minimize the engagement view programmatically
    /// during ongoing engagement. If you do so, the chat bubble appears.
    ///
    public func minimize() {
        rootCoordinator?.minimize()
    }

    /// Maximizes engagement view if ongoing engagement exists.
    /// Throws error if ongoing engagement not exist.
    /// Use this function for resuming engagement view if bubble is hidden
    /// programmatically and you need to present engagement view.
    public func resume() throws {
        guard engagement != .none else { throw GliaError.engagementNotExist }
        rootCoordinator?.maximize()
    }

    /// This custom message renderer used for rendering AI custom cards.
    /// Glia Widgets contains implementation for HTML based custom cards. 
    /// See MessegeRenderer.webRenderer
    ///
    /// - Parameters:
    ///   - messageRenderer: Custom message renderer.
    ///
    public func setChatMessageRenderer(messageRenderer: MessageRenderer?) {
        self.messageRenderer = messageRenderer
    }

    /// Clear visitor session
    ///
    /// - Parameters:
    ///   - completion: Completion handler.
    ///
    /// - Important: Note, that in case of ongoing engagement, `clearVisitorSession` must be called
    ///   after ending engagement, because `GliaError.clearingVisitorSessionDuringEngagementIsNotAllowed`
    ///   will occur otherwise.
    ///
    public func clearVisitorSession(_ completion: @escaping (Result<Void, Error>) -> Void) {
        loggerPhase.logger.prefixed(Self.self).info("Clear visitor session")
        guard environment.coreSdk.getNonTransferredSecureConversationEngagement() == nil else {
            completion(.failure(GliaError.clearingVisitorSessionDuringEngagementIsNotAllowed))
            return
        }
        environment.coreSdk.clearSession()
        completion(.success(()))
    }

    /// Fetch current Visitor's information.
    ///
    /// The information provided by this endpoint is available to all the operators observing
    /// or interacting with the visitor. This means that this endpoint can be used to provide
    /// additional context about the visitor to the operators.
    ///
    /// - Parameters:
    ///   - completion: A callback that will return the update result or `SalemoveError`
    ///
    /// If the request is unsuccessful for any reason then the completion will have an Error.
    /// The Error may have one of the following causes:
    ///
    /// - `GliaCoreSDK.GeneralError.internalError`
    /// - `GliaCoreSDK.GeneralError.networkError`
    /// - `GliaCoreSDK.ConfigurationError.invalidSite`
    /// - `GliaCoreSDK.ConfigurationError.invalidEnvironment`
    /// - `GliaError.sdkIsNotConfigured`
    ///
    /// - Important: Note, that in case of engagement has not been started yet,
    ///   `configure(with:uiConfig:assetsBuilder:completion:)` must be called prior to
    ///   this method, because `GliaError.sdkIsNotConfigured` will occur otherwise.
    ///
    public func getVisitorInfo(completion: @escaping (Result<VisitorInfo, Error>) -> Void) {
        guard configuration != nil else {
            completion(.failure(GliaError.sdkIsNotConfigured))
            return
        }
        Task {
            do {
                let visitorInfo = try await environment.coreSdk.getVisitorInfo()
                completion(.success(visitorInfo))
            } catch {
                completion(.failure(error))
            }
        }
    }

    /// Update current Visitor's information.
    ///
    /// The information provided by this endpoint is available to all the operators observing
    /// or interacting with the visitor. This means that this endpoint can be used to provide
    /// additional context about the visitor to the operators.
    ///
    /// In a similar manner custom attributes can be also be used to provide additional context. 
    /// For example, if your site separates paying users from free users, then setting a custom
    /// attribute of 'user_type' with a value of either 'free' or 'paying' depending on the visitor's
    /// account can help operators prioritize different visitors.
    ///
    /// - Parameters:
    ///   - info: The information for updating Visitor
    ///   - completion: A callback that will return the update result or `SalemoveError`
    ///
    /// If the request is unsuccessful for any reason then the completion will have an Error.
    /// The Error may have one of the following causes:
    ///
    /// - `GliaCoreSDK.GeneralError.internalError`
    /// - `GliaCoreSDK.GeneralError.networkError`
    /// - `GliaCoreSDK.ConfigurationError.invalidSite`
    /// - `GliaCoreSDK.ConfigurationError.invalidEnvironment`
    /// - `GliaError.sdkIsNotConfigured`
    ///
    /// - Important: Note, that in case of engagement has not been started yet,
    ///   `configure(with:uiConfig:assetsBuilder:completion:)` must be called prior to
    ///   this method, because `GliaError.sdkIsNotConfigured` will occur otherwise.
    ///
    public func updateVisitorInfo(
        _ info: VisitorInfoUpdate,
        completion: @escaping (Result<Bool, Error>) -> Void
    ) {
        guard configuration != nil else {
            completion(.failure(GliaError.sdkIsNotConfigured))
            return
        }
        Task {
            do {
                let result = try await environment.coreSdk.updateVisitorInfo(info)
                completion(.success(result))
            } catch {
                completion(.failure(error))
            }
        }
    }

    /// Ends active engagement if existing and closes Widgets SDK UI (includes bubble).
    public func endEngagement(_ completion: @escaping (Result<Void, Error>) -> Void) {
        loggerPhase.logger.prefixed(Self.self).info("End engagement by integrator")

        defer {
            onEvent?(.ended)
            rootCoordinator = nil
        }

        guard configuration != nil else {
            completion(.failure(GliaError.sdkIsNotConfigured))
            return
        }
        Task {
            do {
                try await interactor?.endSession()
                completion(.success(()))
            } catch {
                completion(.failure(error))
            }
        }
    }

    /// List all queues of the configured site. It is also possible to monitor queues changes with
    /// [subscribeForUpdates](x-source-tag://subscribeForUpdates) method. If the request is unsuccessful
    /// for any reason then the completion will have an Error.
    /// 
    /// - Parameters:
    ///   - completion: A callback that will return the Result struct with `Queue` list or `GliaCoreError`.
    ///
    public func getQueues(_ completion: @escaping (Result<[Queue], Error>) -> Void) {
        guard configuration != nil else {
            completion(.failure(GliaError.sdkIsNotConfigured))
            return
        }

        Task {
            do {
                let queues = try await environment.coreSdk.getQueues()
                completion(.success(queues))
            } catch {
                completion(.failure(error))
            }
        }
    }

    /// Configure log level
    ///
    /// - parameters:
    /// - level: One of the 'LogLevel' values that the logger should use
    ///
    @_spi(CortexFinancial)
    public func configureLogLevel(level: GliaCoreSDK.LogLevel) {
        environment.coreSdk.configureLogLevel(level)
    }
}

// MARK: - Internal
extension Glia {
    @discardableResult
    func setupInteractor(
        configuration: Configuration
    ) -> Interactor {
        let interactor = Interactor(
            visitorContext: configuration.visitorContext,
            environment: .create(
                with: environment,
                log: loggerPhase.logger,
                queuesMonitor: queuesMonitor
            )
        )

        interactor.state = environment.coreSdk
            .getNonTransferredSecureConversationEngagement()?.engagedOperator
            .map(InteractorState.engaged) ?? interactor.state

        environment.coreSDKConfigurator.configureWithInteractor(interactor)
        self.interactor = interactor

        return interactor
    }

    /// Used to restore a bubble for Secure Conversation engagement:
    /// - started by accepting engagement request;
    /// - started by Outbound message;
    /// - restored from Follow Up.
    func startObservingInteractorEvents() {
        interactor?.addObserver(self) { [weak self] event in
            // We need to handle `engaged` state only to restore an engagement.
            guard
                case let .stateChanged(interactorState) = event,
                case .engaged = interactorState
            else { return }

            self?.restoreOngoingEngagementIfPresent()
        }
    }

    func stopObservingInteractorEvents() {
        interactor?.removeObserver(self)
    }
}

#if DEBUG
extension Glia {
    /// Used for unit tests only
    var isConfigured: Bool {
        configuration != nil
    }
}
#endif
