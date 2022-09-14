import Foundation

extension Glia {

    public func startEngagementWithConfig(
        engagement: EngagementKind,
        uiConfig: RemoteConfiguration,
        theme: Theme = Theme(),
        features: Features = .all,
        sceneProvider: SceneProvider? = nil
    ) throws {

        // Apply remote configuration
        theme.applyRemoteConfiguration(uiConfig)

        try startEngagement(
            engagementKind: engagement,
            theme: theme,
            features: features,
            sceneProvider: sceneProvider
        )
    }
}
