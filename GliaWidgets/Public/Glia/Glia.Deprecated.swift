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

    /// Deprecated, use ``Glia.configure(with:uiConfig:assetsBuilder:completion)`` instead.
    @available(*, deprecated, message: "Deprecated, use ``Glia.configure(with:uiConfig:assetsBuilder:completion:)`` instead.")
    public func configure(
        with configuration: Configuration,
        queueId: String,
        uiConfig: RemoteConfiguration? = nil,
        assetsBuilder: RemoteConfiguration.AssetsBuilder = .standard,
        completion: (() -> Void)? = nil
    ) throws {
        guard environment.coreSdk.getCurrentEngagement() == nil else {
            throw GliaError.configuringDuringEngagementIsNotAllowed
        }
        self.uiConfig = uiConfig
        self.assetsBuilder = assetsBuilder

        let createdInteractor = Interactor(
            configuration: configuration,
            queueIds: [queueId],
            environment: .init(coreSdk: environment.coreSdk, gcd: environment.gcd)
        )

        interactor = createdInteractor

        if let callback = completion {
            createdInteractor.withConfiguration { [weak createdInteractor, weak self] in
                guard let createdInteractor, let self else { return }

                self.stringProviding = .init(getRemoteString: self.environment.coreSdk.localeProvider.getRemoteString)

                createdInteractor.state = self.environment.coreSdk
                    .getCurrentEngagement()?.engagedOperator
                    .map(InteractorState.engaged) ?? createdInteractor.state
                callback()
            }
        }

        startObservingInteractorEvents()
    }

    /// Deprecated, use ``Glia.startEngagement(engagementKind:in:theme:features:sceneProvider:)`` instead.
    @available(*,
         deprecated,
         message: "Deprecated, use ``Glia.startEngagement(engagementKind:in:theme:features:sceneProvider:)`` instead."
    )
    public func startEngagement(
        engagementKind: EngagementKind,
        theme: Theme = Theme(),
        features: Features = .all,
        sceneProvider: SceneProvider? = nil
    ) throws {
        try startEngagement(
            engagementKind: engagementKind,
            in: [],
            theme: theme,
            features: features,
            sceneProvider: sceneProvider
        )
    }

    /// Deprecated, use ``Glia.configure(with:uiConfig:assetsBuilder:completion:)`` and ``Glia.startEngagement(engagementKind:in:theme:features:sceneProvider:)`` instead.
    @available(*,
         deprecated,
         message: """
            Deprecated, use ``Glia.configure(with:uiConfig:assetsBuilder:completion:)`` and \
            ``Glia.startEngagement(engagementKind:in:theme:features:sceneProvider:)`` instead.
            """
    )
    public func start(
        _ engagementKind: EngagementKind,
        configuration: Configuration,
        queueID: String,
        theme: Theme = Theme(),
        features: Features = .all,
        sceneProvider: SceneProvider? = nil
    ) throws {
        let completion = { [weak self] in
            try self?.startEngagement(
                engagementKind: engagementKind,
                theme: theme,
                features: features,
                sceneProvider: sceneProvider
            )
        }
        do {
            try configure(
                with: configuration,
                queueId: queueID
            ) {
                try? completion()
            }
        } catch GliaError.configuringDuringEngagementIsNotAllowed {
            try completion()
        }
    }

    /// Deprecated, use ``Glia.startEngagementWithConfig(engagement:in:uiConfig:assetsBuilder:features:sceneProvider:)`` instead.
    @available(*,
                deprecated,
                message: """
            Deprecated, use ``Glia.startEngagementWithConfig(engagement:in:uiConfig:assetsBuilder:features:sceneProvider:)`` instead.
            """
    )
    public func startEngagementWithConfig(
        engagement: EngagementKind,
        uiConfig: RemoteConfiguration,
        assetsBuilder: RemoteConfiguration.AssetsBuilder = .standard,
        features: Features = .all,
        sceneProvider: SceneProvider? = nil
    ) throws {
        try startEngagementWithConfig(
            engagement: engagement,
            in: [],
            uiConfig: uiConfig,
            assetsBuilder: assetsBuilder,
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
