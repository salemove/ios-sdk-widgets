import Foundation
import GliaCoreSDK

extension Glia {
    /// Set up and returns parameters needed to start or restore engagement
    func getEngagementParameters(
        configuration: Configuration,
        interactor: Interactor
    ) -> EngagementParameters {
        // It is assumed that `features` to be provided from `configure` or via deprecated `startEngagement` method.
        let features = self.features ?? []

        // Apply company name to theme and get the modified theme
        let modifiedTheme = applyCompanyName(using: configuration, theme: theme)

        let viewFactory = ViewFactory(
            with: modifiedTheme,
            messageRenderer: messageRenderer,
            environment: .create(
                with: environment,
                loggerPhase: loggerPhase
            )
        )

        // If ongoing engagement exists on Core SDK side the engagement kind should be corrected
        // to correct one before restoring it.
        var ongoingEngagementMediaStreams = environment.coreSdk.getNonTransferredSecureConversationEngagement()?.mediaStreams
        // Currently, CoreSDK can't restore video stream
        if let media = ongoingEngagementMediaStreams {
            ongoingEngagementMediaStreams = .init(audio: media.audio, video: nil)
        }

        return EngagementParameters(
            viewFactory: viewFactory,
            interactor: interactor,
            ongoingEngagementMediaStreams: ongoingEngagementMediaStreams,
            features: features,
            configuration: configuration
        )
    }

    func resolveEngagementState(
        engagementKind: EngagementKind,
        sceneProvider: SceneProvider?,
        configuration: Configuration,
        interactor: Interactor,
        features: Features,
        viewFactory: ViewFactory,
        ongoingEngagementMediaStreams: Engagement.Media?
    ) throws {
        /// If during enqueued state the visitor initiates another engagement, we avoid cancelling the queue
        /// ticket and adding a new one, by monitoring the new engagement kind. If the engagement kind matches
        /// the current enqueued engagement kind, then we resume the old, and do not start a new one
        if let enqueueingEngagementKind = interactor.state.enqueueingEngagementKind {
            handleEnqueueingEngagement(
                from: engagementKind,
                enqueueingEngagementKind: enqueueingEngagementKind,
                snackBarStyle: viewFactory.theme.snackBar
            )
            return
        }

        guard let currentEngagement = environment.coreSdk.getNonTransferredSecureConversationEngagement() else {
            if case .messaging = engagementKind, !environment.isAuthenticated() {
                throw GliaError.messagingIsNotSupportedForUnauthenticatedVisitor
            }
            // This value can be set to `true` if engagement restoring happened.
            // To prevent missing Live Observation Confirmation dialog to be shown
            // for further engagements, we need to default this value again.
            interactor.skipLiveObservationConfirmations = false

            // Root coordinator is not nil if secure conversation chat transcript is open
            if let rootCoordinator {
                rootCoordinator.maximize()
            } else {
                startRootCoordinator(
                    with: interactor,
                    viewFactory: viewFactory,
                    sceneProvider: sceneProvider,
                    engagementKind: ongoingEngagementMediaStreams.map { EngagementKind(media: $0) } ?? engagementKind,
                    features: features
                )
            }
            return
        }

        if currentEngagement.source == .callVisualizer {
            handleOngoingCallVisualizer(
                from: engagementKind,
                ongoingEngagement: currentEngagement,
                snackBarStyle: viewFactory.theme.snackBar
            )
        } else {
            switch engagementKind {
            case .chat, .messaging:
                handleOngoingEngagement(
                    shoulShowSnackBar: currentEngagement.mediaStreams.containsMediaDirection,
                    ongoingEngagement: currentEngagement,
                    snackBarStyle: viewFactory.theme.snackBar,
                    configuration: configuration,
                    interactor: interactor,
                    features: features
                )
            case .audioCall, .videoCall:
                handleOngoingEngagement(
                    shoulShowSnackBar: !currentEngagement.mediaStreams.containsMediaDirection,
                    ongoingEngagement: currentEngagement,
                    snackBarStyle: viewFactory.theme.snackBar,
                    configuration: configuration,
                    interactor: interactor,
                    features: features
                )
            case .none:
                break
            }
        }
    }

    func companyName(
        using configuration: Configuration,
        themeCompanyName: String?
    ) -> String {
        let companyNameStringKey = "general.company_name"

        // Company name has been set on the custom locale and is not empty.
        if let remoteCompanyName = stringProvidingPhase(companyNameStringKey),
            !remoteCompanyName.isEmpty {
            return remoteCompanyName
        }
        // As the default value in the theme is not empty, it means that
        // the integrator has set a value on the theme itself. Return that
        // same value.
        else if let themeCompanyName, !themeCompanyName.isEmpty {
            return themeCompanyName
        }
        // Integrator has not set a company name in the custom locale,
        // but has set it on the configuration.
        else if !configuration.companyName.isEmpty {
            return configuration.companyName
        }
        // Integrator has not set a company name anywhere, use the default.
        else {
            // This will return the fallback value every time, because we have
            // already determined that the remote string is empty.
            return Localization.General.companyNameLocalFallbackOnly
        }
    }

    func applyCompanyName(using configuration: Configuration, theme: Theme) -> Theme {
        theme.chat.connect.queue.firstText = companyName(
            using: configuration,
            themeCompanyName: theme.chat.connect.queue.firstText
        )
        theme.call.connect.queue.firstText = companyName(
            using: configuration,
            themeCompanyName: theme.call.connect.queue.firstText
        )
        return theme
    }

    func startRootCoordinator(
        with interactor: Interactor,
        viewFactory: ViewFactory,
        sceneProvider: SceneProvider?,
        engagementKind: EngagementKind,
        features: Features,
        maximize: Bool = true
    ) {
        let engagementLaunching: EngagementCoordinator.EngagementLaunching

        switch (pendingInteraction?.hasPendingInteraction ?? false, engagementKind) {
        case (false, _):
            // if there is no pending Secure Conversation, open regular flow.
            engagementLaunching = .direct(kind: engagementKind)

        case (true, .messaging(.welcome)):
            // if there is pending Secure Conversation and requested `EngagementKind` is messaging,
            // then open ChatTranscript screen.
            engagementLaunching = .direct(kind: .messaging(.chatTranscript))

        case (true, .messaging(.chatTranscript)):
            engagementLaunching = .direct(kind: .messaging(.chatTranscript))

        case (true, _):
            // if there is pending Secure Conversation and requested `EngagementKind` is not messaging,
            // then open ChatTranscript screen and present Leave Current Conversation dialog.
            // If user presses Leave button, then ChatTranscript screen will be replaced with proper Chat/Call screen.
            engagementLaunching = .indirect(kind: .messaging(.chatTranscript), initialKind: engagementKind)
        }
        rootCoordinator = self.environment.rootCoordinator(
            interactor: interactor,
            viewFactory: viewFactory,
            sceneProvider: sceneProvider,
            engagementLaunching: engagementLaunching,
            features: features,
            engagementRestorationState: { [weak self] in
                return self?.engagementRestorationState ?? .none
            },
            environment: .create(
                with: environment,
                loggerPhase: loggerPhase,
                markUnreadMessagesDelay: { self.markUnreadMessagesDelay },
                maximumUploads: { self.maximumUploads },
                viewFactory: viewFactory,
                alertManager: alertManager,
                queuesMonitor: queuesMonitor,
                createEntryWidget: { [weak self] configuration in
                    guard let self else {
                        throw GliaError.internalError
                    }
                    return try self.getEntryWidget(
                        queueIds: interactor.queueIds ?? [],
                        configuration: configuration
                    )
                },
                hasPendingInteraction: { [weak self] in
                    self?.pendingInteraction?.hasPendingInteraction ?? false
                }
            )
        )
        rootCoordinator?.delegate = { [weak self] event in self?.handleCoordinatorEvent(event) }
        rootCoordinator?.start(maximize: maximize)
    }

    private func handleCoordinatorEvent(_ event: EngagementCoordinator.DelegateEvent) {
        switch event {
        case .started:
            onEvent?(.started)
        case .engagementChanged(let engagementKind):
            onEvent?(.engagementChanged(engagementKind))
        case .ended:
            rootCoordinator = nil
            onEvent?(.ended)
        case .closed:
            rootCoordinator = nil
            // If engagement was started/restored while visitor was
            // on SecureConversation Confirmation screen, we need to restore the bubble.
            restoreOngoingEngagementIfPresent()
        case .minimized:
            onEvent?(.minimized)
        case .maximized:
            onEvent?(.maximized)
        }
    }

    private func handleOngoingCallVisualizer(
        from engagementKind: EngagementKind,
        ongoingEngagement: Engagement,
        snackBarStyle: Theme.SnackBarStyle
    ) {
        if engagementKind == .videoCall && ongoingEngagement.mediaStreams.video != nil {
            callVisualizer.restoreVideoIfPossible()
        } else {
            showSnackBar(
                with: Localization.EntryWidget.CallVisualizer.description,
                style: snackBarStyle
            )
        }
    }

    private func handleOngoingEngagement(
        shoulShowSnackBar: Bool,
        ongoingEngagement: Engagement,
        snackBarStyle: Theme.SnackBarStyle,
        configuration: Configuration,
        interactor: Interactor,
        features: Features
    ) {
        if shoulShowSnackBar {
            showSnackBar(
                with: Localization.EntryWidget.CallVisualizer.description,
                style: snackBarStyle
            )
        } else {
            if let rootCoordinator {
                rootCoordinator.maximize()
            } else {
                self.restoreOngoingEngagement(
                    configuration: configuration,
                    currentEngagement: ongoingEngagement,
                    interactor: interactor,
                    features: features,
                    maximize: true
                )
            }
        }
    }

    private func handleEnqueueingEngagement(
        from engagementKind: EngagementKind,
        enqueueingEngagementKind: EngagementKind,
        snackBarStyle: Theme.SnackBarStyle
    ) {
        switch engagementKind {
        case .chat, .messaging:
            if enqueueingEngagementKind == .chat || enqueueingEngagementKind.isMessaging {
                rootCoordinator?.maximize()
            } else {
                showSnackBar(
                    with: Localization.EntryWidget.CallVisualizer.description,
                    style: snackBarStyle
                )
            }
        case .audioCall, .videoCall:
            if enqueueingEngagementKind == .audioCall || enqueueingEngagementKind == .videoCall {
                rootCoordinator?.maximize()
            } else {
                showSnackBar(
                    with: Localization.EntryWidget.CallVisualizer.description,
                    style: snackBarStyle
                )
            }
        case .none:
            break
        }
    }

    /// The `EngagementParameters` encapsulates all parameters required to initiate or restore the coordinator
    struct EngagementParameters {
        let viewFactory: ViewFactory
        let interactor: Interactor
        let ongoingEngagementMediaStreams: Engagement.Media?
        let features: Features
        let configuration: Configuration
    }
}

extension GliaCoreSDK.Engagement.Media {
    var containsMediaDirection: Bool {
        audio != nil || video != nil
    }
}
