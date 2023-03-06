import Foundation

extension Glia {

    /// Starts the engagement.
    ///
    /// - Parameters:
    ///   - engagementKind: Engagement media type.
    ///   - uiConfig: Remote UI configuration.
    ///   - assetsBuilder: Provides assets for remote configuration.
    ///   - features: Set of features to be enabled in the SDK.
    ///   - sceneProvider: Used to provide `UIWindowScene` to the framework. Defaults to the first active foreground scene.
    ///
    /// - throws:
    ///   - `SalemoveSDK.ConfigurationError.invalidSite`
    ///   - `SalemoveSDK.ConfigurationError.invalidEnvironment`
    ///   - `SalemoveSDK.ConfigurationError.invalidAppToken`
    ///   - `GliaError.engagementExists
    ///   - `GliaError.sdkIsNotConfigured`
    ///
    /// - Important: Note, that `configure(with:queueID:visitorContext:)` must be called initially prior to this method,
    /// because `GliaError.sdkIsNotConfigured` will occur otherwise.
    ///
    public func startEngagementWithConfig(
        engagement: EngagementKind,
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
        let theme = Theme()
        theme.applyRemoteConfiguration(
            uiConfig,
            assetsBuilder: assetsBuilder
        )

        try startEngagement(
            engagementKind: engagement,
            theme: theme,
            features: features,
            sceneProvider: sceneProvider
        )
    }
}
