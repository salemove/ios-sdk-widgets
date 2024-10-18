import Foundation
import GliaCoreSDK

extension Glia {
    /// Starts the engagement.
    ///
    /// - Parameters:
    ///   - engagementKind: Engagement media type.
    ///   - in: Queue identifiers
    ///   - sceneProvider: Used to provide `UIWindowScene` to the framework. Defaults to
    ///     the first active foreground scene.
    ///
    /// - throws:
    ///   - `GliaCoreSDK.ConfigurationError.invalidSite`
    ///   - `GliaCoreSDK.ConfigurationError.invalidEnvironment`
    ///   - `GliaError.engagementExists
    ///   - `GliaError.sdkIsNotConfigured`
    ///
    /// - Important: Note, that `configure(with:uiConfig:assetsBuilder:completion:)` must be called
    ///   initially prior to this method, because `GliaError.sdkIsNotConfigured` will occur otherwise.
    ///
    public func startEngagement(
        of engagementKind: EngagementKind, // To help compiler to avoid ambiguity, change signature of `engagementKind` parameter.
        in queueIds: [String] = [],
        sceneProvider: SceneProvider? = nil
    ) throws {
        let parameters = try getEngagementParameters(in: queueIds)

        try resolveEngangementState(
            engagementKind: engagementKind,
            sceneProvider: sceneProvider,
            configuration: parameters.configuration,
            interactor: parameters.interactor,
            features: parameters.features,
            viewFactory: parameters.viewFactory,
            ongoingEngagementMediaStreams: parameters.ongoingEngagementMediaStreams
        )
    }

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

    func resolveEngangementState(
        engagementKind: EngagementKind,
        sceneProvider: SceneProvider?,
        configuration: Configuration,
        interactor: Interactor,
        features: Features,
        viewFactory: ViewFactory,
        ongoingEngagementMediaStreams: Engagement.Media?
    ) throws {
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
        rootCoordinator = self.environment.rootCoordinator(
            interactor: interactor,
            viewFactory: viewFactory,
            sceneProvider: sceneProvider,
            engagementKind: engagementKind,
            screenShareHandler: environment.screenShareHandler,
            features: features,
            environment: .create(
                with: environment,
                loggerPhase: loggerPhase,
                maximumUploads: { self.maximumUploads },
                viewFactory: viewFactory,
                alertManager: alertManager
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
