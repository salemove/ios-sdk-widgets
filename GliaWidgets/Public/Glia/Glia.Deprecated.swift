import GliaCoreSDK

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
}

extension Glia.Authentication {
    @available(*, deprecated, message: "Use Glia.Authentication.authenticate(with:accessToken:completion:) instead.")
    public func authenticate(
        with idToken: IdToken,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        self.authenticateWithIdToken(
            idToken,
            nil,
            completion
        )
    }
}
