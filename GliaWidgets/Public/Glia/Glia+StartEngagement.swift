import Foundation
import GliaCoreSDK

extension Glia {
    /// Starts the engagement.
    ///
    /// - Parameters:
    ///   - engagementKind: Engagement media type.
    ///   - in: Queue identifiers
    ///   - features: Set of features to be enabled in the SDK.
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
        engagementKind: EngagementKind,
        in queueIds: [String] = [],
        features: Features = .all,
        sceneProvider: SceneProvider? = nil
    ) throws {
        // It checks if ongoing engagement exists on WidgetsSDK side, if it doesn't but ongoing engagement exists
        // on CoreSDK side, it will be restored.
        guard engagement == .none else { throw GliaError.engagementExists }
        guard let configuration = self.configuration else { throw GliaError.sdkIsNotConfigured }
        if let engagement = environment.coreSdk.getCurrentEngagement(),
            engagement.source == .callVisualizer {
            throw GliaError.callVisualizerEngagementExists
        }

        // Creates interactor instance
        let createdInteractor = setupInteractor(
            configuration: configuration,
            queueIds: queueIds
        )

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

        startRootCoordinator(
            with: createdInteractor,
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

    private func applyCompanyName(using configuration: Configuration, theme: Theme) -> Theme {
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
}
