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
    init(media: CoreSdkClient.Engagement.Media) {
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

// swiftlint:disable type_body_length
/// Glia's engagement interface.
public class Glia {
    /// A singleton to access the Glia's interface.
    public static let sharedInstance = Glia(environment: .live)

    /// Current engagement media type.
    public var engagement: EngagementKind {
        environment.openTelemetry.logger.logMethodUse(
            sdkType: .widgetsSdk,
            className: Self.self,
            methodName: "engagement"
        )
        return rootCoordinator?.engagementLaunching.currentKind ?? .none
    }

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

        environment.openTelemetry.setGlobalAttribute(.string(StaticValues.sdkVersion), forKey: .sdkWidgetsVersion)
        environment.openTelemetry.logger.i(.widgetsSdkSetup)

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
        try prepareForConfiguration(
            configuration: configuration,
            theme: theme,
            uiConfig: uiConfig,
            assetsBuilder: assetsBuilder,
            features: features,
            methodParams: ["configuration", "theme", "uiConfig", "assetsBuilder", "features", "completion"]
        )

        Task { [weak self] in
            guard let self else { return }
            do {
                try await self.completeConfiguration(
                    configuration: configuration,
                    uiConfig: uiConfig,
                    features: features
                )
                await MainActor.run {
                    completion(.success(()))
                }
            } catch {
                await MainActor.run {
                    completion(.failure(error))
                }
            }
        }
    }

    private func prepareForConfiguration(
        configuration: Configuration,
        theme: Theme,
        uiConfig: RemoteConfiguration?,
        assetsBuilder: RemoteConfiguration.AssetsBuilder,
        features: Features,
        methodParams: [String]
    ) throws {
        environment.openTelemetry.logger.logMethodUse(
            sdkType: .widgetsSdk,
            className: Self.self,
            methodName: "configure",
            methodParams: methodParams
        )

        guard environment.coreSdk.getNonTransferredSecureConversationEngagement() == nil else {
            let error = GliaError.configuringDuringEngagementIsNotAllowed
            environment.openTelemetry.logger.e(.widgetsSdkConfigured, error: error)
            throw error
        }

        environment.openTelemetry.logger.i(.widgetsSdkConfiguring) {
            $0[.apiKeyId] = .string(configuration.authorizationMethod.id)
            $0[.environment] = .string(configuration.environment.rawValue)
            $0[.localeCode] = .string(configuration.manualLocaleOverride ?? "N/A")
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
    }
    /// Minimizes engagement view if ongoing engagement exists.
    /// Use this function to minimize the engagement view programmatically
    /// during ongoing engagement. If you do so, the chat bubble appears.
    ///
    public func minimize() {
        environment.openTelemetry.logger.logMethodUse(
            sdkType: .widgetsSdk,
            className: Self.self,
            methodName: "minimize"
        )
        rootCoordinator?.minimize()
    }

    /// Maximizes engagement view if ongoing engagement exists.
    /// Throws error if ongoing engagement not exist.
    /// Use this function for resuming engagement view if bubble is hidden
    /// programmatically and you need to present engagement view.
    public func resume() throws {
        environment.openTelemetry.logger.logMethodUse(
            sdkType: .widgetsSdk,
            className: Self.self,
            methodName: "resume"
        )
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
        environment.openTelemetry.logger.logMethodUse(
            sdkType: .widgetsSdk,
            className: Self.self,
            methodName: "setChatMessageRenderer",
            methodParams: ["messageRenderer"]
        )
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
        Task {
            do {
                try await clearVisitorSession()
                completion(.success(()))
            } catch {
                completion(.failure(error))
            }
        }
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
        Task {
            do {
                let visitorInfo = try await getVisitorInfo()
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
        Task {
            do {
                let result = try await updateVisitorInfo(info)
                completion(.success(result))
            } catch {
                completion(.failure(error))
            }
        }
    }

    /// Ends active engagement if existing and closes Widgets SDK UI (includes bubble).
    public func endEngagement(_ completion: @escaping (Result<Void, Error>) -> Void) {
        Task {
            do {
                try await endEngagement()
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
        Task {
            do {
                let queues = try await getQueues()
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
        environment.openTelemetry.logger.logMethodUse(
            sdkType: .widgetsSdk,
            className: Self.self,
            methodName: "configureLogLevel",
            methodParams: ["level"]
        )
        environment.coreSdk.configureLogLevel(level)
    }
}
// swiftlint:enable type_body_length

// MARK: - Internal
extension Glia {
    func completeConfiguration(
        configuration: Configuration,
        uiConfig: RemoteConfiguration?,
        features: Features
    ) async throws {
        do {
            try await environment.coreSDKConfigurator.configureWithConfiguration(configuration)
            try await MainActor.run {
                try handleCoreSDKConfigured(
                    configuration: configuration,
                    uiConfig: uiConfig,
                    features: features
                )
            }
        } catch {
            throw mapCoreSDKConfigurationFailure(error)
        }
    }

    @MainActor
    func handleCoreSDKConfigured(
        configuration: Configuration,
        uiConfig: RemoteConfiguration?,
        features: Features
    ) throws {
        defer {
            loggerPhase.logger.prefixed(Self.self).info("Initialize Glia Widgets SDK")
            if uiConfig != nil {
                loggerPhase.logger.remoteLogger?.prefixed(Self.self)
                    .info("Setting Unified UI Config")
            }
        }
        // Storing `configuration` needs to be done once configuring SDK is complete
        // Otherwise integrator can call `configure` and `startEngagement`
        // asynchronously, without waiting configuration completion.
        self.configuration = configuration

        let interactor = setupInteractor(configuration: configuration)
        self.interactor = interactor
        callVisualizer.startObservingInteractorEvents()

        let getRemoteString = environment.coreSdk.localeProvider.getRemoteString
        stringProvidingPhase = .configured(getRemoteString)

        // PendingInteraction is essential part of SC flow, so it's not
        // valid to consider SDK configured if PI is not created.
        do {
            pendingInteraction = try .init(environment: .init(
                client: environment.coreSdk,
                interactorPublisher: Just(interactor).eraseToAnyPublisher()
            ))
        } catch let error as SecureConversations.PendingInteraction.Error {
            switch error {
            case .subscriptionFailure:
                throw GliaError.internalEventSubscriptionFailure
            }
        } catch {
            throw GliaError.internalError
        }
        startObservingInteractorEvents()
        environment.openTelemetry.logger.i(.widgetsSdkConfigured)

        guard let currentEngagement = environment.coreSdk.getNonTransferredSecureConversationEngagement() else { return }

        if currentEngagement.source == .callVisualizer {
            Task { @MainActor in
                await callVisualizer.handleRestoredEngagement()
            }
        } else {
            Task { @MainActor in
                await restoreOngoingEngagement(
                    configuration: configuration,
                    currentEngagement: currentEngagement,
                    interactor: interactor,
                    features: features,
                    maximize: false
                )
            }
        }
    }

    func mapCoreSDKConfigurationFailure(_ error: Error) -> Error {
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
        return errorForCompletion
    }

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

            Task { @MainActor in
                await self?.restoreOngoingEngagementIfPresent()
            }
        }
    }

    func stopObservingInteractorEvents() {
        interactor?.removeObserver(self)
    }
}

public extension Glia {
    /// Sets up the SDK with a specific engagement configuration without
    /// starting an engagement.
    ///
    /// This method completes after the Core SDK is configured, the Widgets SDK
    /// state is prepared, and engagement restoration has been scheduled when an
    /// existing engagement is available.
    ///
    /// - Parameters:
    ///   - configuration: Engagement configuration.
    ///   - theme: A custom theme to use with engagements.
    ///   - uiConfig: Remote UI configuration.
    ///   - assetsBuilder: Provides assets for remote configuration.
    ///   - features: Set of features to enable in the SDK.
    /// - Throws:
    ///   - `GliaError.configuringDuringEngagementIsNotAllowed` if a
    ///     non-transferred secure conversation is active.
    ///   - `ConfigurationError` if Core SDK configuration fails.
    func configure(
        with configuration: Configuration,
        theme: Theme = Theme(),
        uiConfig: RemoteConfiguration? = nil,
        assetsBuilder: RemoteConfiguration.AssetsBuilder = .standard,
        features: Features = .all
    ) async throws {
        try prepareForConfiguration(
            configuration: configuration,
            theme: theme,
            uiConfig: uiConfig,
            assetsBuilder: assetsBuilder,
            features: features,
            methodParams: ["configuration", "theme", "uiConfig", "assetsBuilder", "features"]
        )
        try await completeConfiguration(
            configuration: configuration,
            uiConfig: uiConfig,
            features: features
        )
    }

    /// Clears the current visitor session.
    ///
    /// - Important: If an engagement is ongoing, end the engagement before
    ///   calling this method. Otherwise
    ///   `GliaError.clearingVisitorSessionDuringEngagementIsNotAllowed` is
    ///   thrown.
    /// - Throws: `GliaError.clearingVisitorSessionDuringEngagementIsNotAllowed`
    ///   when a non-transferred secure conversation is active.
    func clearVisitorSession() async throws {
        environment.openTelemetry.logger.logMethodUse(
            sdkType: .widgetsSdk,
            className: Self.self,
            methodName: "clearVisitorSession",
            methodParams: []
        )
        loggerPhase.logger.prefixed(Self.self).info("Clear visitor session")
        guard environment.coreSdk.getNonTransferredSecureConversationEngagement() == nil else {
            throw GliaError.clearingVisitorSessionDuringEngagementIsNotAllowed
        }
        environment.coreSdk.clearSession()
    }

    /// Fetches the current visitor's information.
    ///
    /// The returned information is available to operators observing or
    /// interacting with the visitor and can provide additional visitor context.
    ///
    /// - Returns: Current visitor information.
    /// - Throws:
    ///   - `GliaError.sdkIsNotConfigured` if the SDK has not been configured.
    ///   - `GliaCoreSDK.GeneralError.internalError`
    ///   - `GliaCoreSDK.GeneralError.networkError`
    ///   - `GliaCoreSDK.ConfigurationError.invalidSite`
    ///   - `GliaCoreSDK.ConfigurationError.invalidEnvironment`
    func getVisitorInfo() async throws -> VisitorInfo {
        environment.openTelemetry.logger.logMethodUse(
            sdkType: .widgetsSdk,
            className: Self.self,
            methodName: "getVisitorInfo",
            methodParams: []
        )
        guard configuration != nil else {
            throw GliaError.sdkIsNotConfigured
        }
        return try await environment.coreSdk.getVisitorInfo()
    }

    /// Updates the current visitor's information.
    ///
    /// The provided information is available to operators observing or
    /// interacting with the visitor. Custom attributes can also provide
    /// additional context, such as account type or visitor priority.
    ///
    /// - Parameter info: Visitor information to update.
    /// - Returns: `true` when the visitor information was updated.
    /// - Throws:
    ///   - `GliaError.sdkIsNotConfigured` if the SDK has not been configured.
    ///   - `GliaCoreSDK.GeneralError.internalError`
    ///   - `GliaCoreSDK.GeneralError.networkError`
    ///   - `GliaCoreSDK.ConfigurationError.invalidSite`
    ///   - `GliaCoreSDK.ConfigurationError.invalidEnvironment`
    func updateVisitorInfo(_ info: VisitorInfoUpdate) async throws -> Bool {
        environment.openTelemetry.logger.logMethodUse(
            sdkType: .widgetsSdk,
            className: Self.self,
            methodName: "updateVisitorInfo",
            methodParams: ["info"]
        )
        guard configuration != nil else {
            throw GliaError.sdkIsNotConfigured
        }
        return try await environment.coreSdk.updateVisitorInfo(info)
    }

    /// Ends the active engagement and closes the Widgets SDK UI, including the
    /// bubble.
    ///
    /// This method performs UI teardown on the main actor.
    ///
    /// - Throws:
    ///   - `GliaError.sdkIsNotConfigured` if the SDK has not been configured.
    ///   - Any error produced while ending the active interactor session.
    @MainActor
    func endEngagement() async throws {
        environment.openTelemetry.logger.logMethodUse(
            sdkType: .widgetsSdk,
            className: Self.self,
            methodName: "endEngagement",
            methodParams: []
        )
        loggerPhase.logger.prefixed(Self.self).info("End engagement by integrator")

        guard configuration != nil else {
            throw GliaError.sdkIsNotConfigured
        }

        guard let interactor else {
            onEvent?(.ended)
            return
        }

        try await interactor.endSession()

        guard let rootCoordinator else {
            onEvent?(.ended)
            return
        }

        rootCoordinator.popCoordinator()
        await withCheckedContinuation { continuation in
            rootCoordinator.end(
                surveyPresentation: .doNotPresentSurvey,
                dismissalCompletion: {
                    continuation.resume()
                }
            )
        }
    }

    /// Fetches all queues for the configured site.
    ///
    /// - Returns: Queue list for the configured site.
    /// - Throws:
    ///   - `GliaError.sdkIsNotConfigured` if the SDK has not been configured.
    ///   - Any Core SDK error produced while fetching queues.
    func getQueues() async throws -> [Queue] {
        environment.openTelemetry.logger.logMethodUse(
            sdkType: .widgetsSdk,
            className: Self.self,
            methodName: "getQueues",
            methodParams: []
        )
        guard configuration != nil else {
            throw GliaError.sdkIsNotConfigured
        }
        return try await environment.coreSdk.getQueues()
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
