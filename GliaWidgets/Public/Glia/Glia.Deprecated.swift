import SalemoveSDK

extension Glia {
    /// Deprecated.
    @available(*, unavailable, message: "Use configure(with:queueId:uiConfig:assetsBuilder:completion:) instead.")
    public func configure(
        with configuration: Configuration,
        queueId: String,
        visitorContext: VisitorContext?,
        completion: (() -> Void)? = nil
    ) throws {
        try self.configure(
            with: configuration,
            queueId: queueId,
            uiConfig: nil,
            completion: completion
        )
    }

    /// Deprecated.
    @available(
        *,
         deprecated,
         message: "Use start(_:configuration:queueID:visitorContext:theme:features:sceneProvider:) with Optional<VisitorContext> instead."
    )
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

    /// Deprecated.
    @available(
        *,
         deprecated,
         message: "Use start(_:configuration:queueID:theme:features:sceneProvider:) instead."
    )
    public func start(
        _ engagementKind: EngagementKind,
        configuration: Configuration,
        queueID: String,
        visitorContext: VisitorContext?,
        theme: Theme = Theme(),
        features: Features = .all,
        sceneProvider: SceneProvider? = nil
    ) throws {
        if visitorContext != nil {
            print("⚠️ visitorContext has been deprecated, please pass visitor context using `Configuration`.")
        }
        try start(
            engagementKind,
            configuration: configuration,
            queueID: queueID,
            theme: theme,
            features: features,
            sceneProvider: sceneProvider
        )
    }

    /// Deprecated, use `clearVisitorSession(_:)` instead.
    @available(
        *,
         deprecated,
         message: "Use clearVisitorSession(_:) instead."
    )
    public func clearVisitorSession() {
        if environment.coreSdk.getCurrentEngagement() != nil {
            print("⚠️ Don't call `clearVisitorSession` during active engagement. Otherwise, it might break the engagement interaction.")
        }
        environment.coreSdk.clearSession()
    }

    /// Deprecated, use ``callVisualizer.showVisitorCodeViewController`` instead.
    @available(*, deprecated, message: "Deprecated, use ``CallVisualizer.showVisitorCodeViewController`` instead.")
    public func requestVisitorCode(completion: @escaping (Result<VisitorCode, Swift.Error>) -> Void) {
        _ = environment.coreSdk.requestVisitorCode(completion)
    }
}
