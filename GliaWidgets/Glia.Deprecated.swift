import SalemoveSDK

extension Glia {
    /// Deprecated.
    @available(*, deprecated, message: "Use configure(with:queueId:visitorContext:) with Optional<VisitorContext> instead.")
    public func configure(
        with configuration: Configuration,
        queueId: String,
        visitorContext: VisitorContext
    ) throws {
        try self.configure(
            with: configuration,
            queueId: queueId,
            visitorContext: Optional(visitorContext)
        )
    }

    /// Deprecated.
// swiftlint: disable line_length
    @available(*, deprecated, message: "Use start(_:configuration:queueID:visitorContext:theme:features:sceneProvider:) with Optional<VisitorContext> instead.")
// swiftlint: enable line_length
    public func start(
        _ engagementKind: EngagementKind,
        configuration: Configuration,
        queueID: String,
        visitorContext: VisitorContext,
        theme: Theme = Theme(),
        features: Features = .all,
        sceneProvider: SceneProvider? = nil
    ) throws {
        try self.start(
            engagementKind,
            configuration: configuration,
            queueID: queueID,
            visitorContext: Optional(visitorContext),
            theme: theme,
            features: features,
            sceneProvider: sceneProvider
        )
    }
}
