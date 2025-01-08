import Foundation
import GliaCoreSDK

extension Glia {
    /// Set up and returns parameters needed to start or restore engagement
    func getEngagementParameters(in queueIds: [String] = []) throws -> EngagementParameters {
        // In order to align behaviour between platforms,
        // `GliaError.engagementExists` is no longer thrown,
        // instead engagement is getting restored.
        guard let configuration else {
            throw GliaError.sdkIsNotConfigured
        }

        guard let interactor else {
            loggerPhase.logger.prefixed(Self.self).warning("Interactor is missing")
            throw GliaError.sdkIsNotConfigured
        }

        // Interactor is initialized during configuration, which means that queueIds need
        // to be set in interactor when startEngagement is called.
        interactor.setQueuesIds(queueIds)

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
        var ongoingEngagementMediaStreams = environment.coreSdk.getCurrentEngagement()?.mediaStreams
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
        if case let .enqueued(_, enqueudEngagementKind) = interactor.state, enqueudEngagementKind == engagementKind, let rootCoordinator {
            rootCoordinator.maximize()
            return
        }

        if let engagement = environment.coreSdk.getCurrentEngagement() {
            if engagement.source == .callVisualizer {
                throw GliaError.callVisualizerEngagementExists
            } else {
                if let rootCoordinator {
                    rootCoordinator.maximize()
                } else {
                    self.restoreOngoingEngagement(
                        configuration: configuration,
                        currentEngagement: engagement,
                        interactor: interactor,
                        features: features,
                        maximize: true
                    )
                }
                loggerPhase.logger.prefixed(Self.self).info("Engagement was restored")
                return
            }
        }

        startRootCoordinator(
            with: interactor,
            viewFactory: viewFactory,
            sceneProvider: sceneProvider,
            engagementKind: ongoingEngagementMediaStreams.map { EngagementKind(media: $0) } ?? engagementKind,
            features: features
        )
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
            screenShareHandler: environment.screenShareHandler,
            features: features,
            environment: .create(
                with: environment,
                loggerPhase: loggerPhase,
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
        case .minimized:
            onEvent?(.minimized)
        case .maximized:
            onEvent?(.maximized)
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
