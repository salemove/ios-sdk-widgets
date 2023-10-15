import Foundation

extension Glia {

    /// Starts the engagement.
    ///
    /// - Parameters:
    ///   - engagementKind: Engagement media type.
    ///   - in: Queue identifiers
    ///   - uiConfig: Remote UI configuration.
    ///   - assetsBuilder: Provides assets for remote configuration.
    ///   - features: Set of features to be enabled in the SDK.
    ///   - sceneProvider: Used to provide `UIWindowScene` to the framework. Defaults to the first active foreground scene.
    ///
    /// - throws:
    ///   - `GliaCoreSDK.ConfigurationError.invalidSite`
    ///   - `GliaCoreSDK.ConfigurationError.invalidEnvironment`
    ///   - `GliaError.engagementExists
    ///   - `GliaError.sdkIsNotConfigured`
    ///
    /// - Important: Note, that `configure(with:queueID:visitorContext:)` must be called initially prior to this method,
    /// because `GliaError.sdkIsNotConfigured` will occur otherwise.
    ///
    public func startEngagementWithConfig(
        engagement: EngagementKind,
        in queueIds: [String],
        uiConfig: RemoteConfiguration,
        assetsBuilder: RemoteConfiguration.AssetsBuilder = .standard,
        features: Features = .all,
        sceneProvider: SceneProvider? = nil
    ) throws {
        // Store uiConfig and assetsBuilder to have ability to
        // apply them for Call Visualizer flow if integrator use
        // old `configure` method
        self.uiConfig = uiConfig
        self.assetsBuilder = assetsBuilder

        // Apply remote configuration
        let theme = Theme(
            uiConfig: uiConfig,
            assetsBuilder: assetsBuilder
        )
        if let config = configuration {
            theme.showsPoweredBy = !config.isWhiteLabelApp
            theme.chat.connect.queue.firstText = config.companyName
            theme.call.connect.queue.firstText = config.companyName
        }

        try startEngagement(
            engagementKind: engagement,
            in: queueIds,
            theme: theme,
            features: features,
            sceneProvider: sceneProvider
        )
    }
}
