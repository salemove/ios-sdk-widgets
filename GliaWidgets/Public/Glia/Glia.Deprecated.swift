import GliaCoreSDK

extension Glia {
    /// Deprecated, use `clearVisitorSession(_:)` instead.
    @available(
        *,
         deprecated,
         message: "Use clearVisitorSession(_:) instead."
    )
    public func clearVisitorSession() {
        loggerPhase.logger.prefixed(Self.self).info("Clear visitor session")
        loggerPhase.logger.oneTime.remoteLogger?.reportDeprecatedMethod(context: Self.self)
        if environment.coreSdk.getCurrentEngagement() != nil {
            print("⚠️ Don't call `clearVisitorSession` during active engagement. Otherwise, it might break the engagement interaction.")
        }
        environment.coreSdk.clearSession()
    }

    /// Deprecated, use ``callVisualizer.showVisitorCodeViewController`` instead.
    @available(*, deprecated, message: "Deprecated, use ``CallVisualizer.showVisitorCodeViewController`` instead.")
    public func requestVisitorCode(completion: @escaping (Result<VisitorCode, Swift.Error>) -> Void) {
        loggerPhase.logger.oneTime.remoteLogger?.reportDeprecatedMethod(context: Self.self)
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
        loggerPhase.logger.oneTime.remoteLogger?.reportDeprecatedMethod(context: Self.self)
        try configure(
            with: configuration,
            uiConfig: uiConfig,
            assetsBuilder: assetsBuilder,
            completion: completion
        )
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
        loggerPhase.logger.oneTime.remoteLogger?.reportDeprecatedMethod(context: Self.self)
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
        loggerPhase.logger.oneTime.remoteLogger?.reportDeprecatedMethod(context: Self.self)
        let completion = { [weak self] in
            try self?.startEngagement(
                engagementKind: engagementKind,
                in: [queueID],
                theme: theme,
                features: features,
                sceneProvider: sceneProvider
            )
        }
        do {
            try configure(with: configuration) {
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
        loggerPhase.logger.oneTime.remoteLogger?.reportDeprecatedMethod(context: Self.self)
        try startEngagementWithConfig(
            engagement: engagement,
            in: [],
            uiConfig: uiConfig,
            assetsBuilder: assetsBuilder,
            features: features,
            sceneProvider: sceneProvider
        )
    }

    /// Deprecated, use the `configure` method that provides a `Result` in its completion instead.
    @available(*, deprecated, message: "Use the `configure` method that provides a `Result` in its completion instead.")
    public func configure(
        with configuration: Configuration,
        uiConfig: RemoteConfiguration? = nil,
        assetsBuilder: RemoteConfiguration.AssetsBuilder = .standard,
        completion: (() -> Void)? = nil
    ) throws {
        loggerPhase.logger.oneTime.remoteLogger?.reportDeprecatedMethod(context: Self.self)
        try configure(
            with: configuration,
            uiConfig: uiConfig,
            assetsBuilder: assetsBuilder
        ) { result in
            defer {
                completion?()
            }
            guard case let .failure(error) = result else { return }
            debugPrint("💥 Core SDK configuration is not valid. Unexpected error='\(error)'.")
        }
    }

    /// Deprecated, use ``Glia.startEngagement(engagementKind:in queueIds:features:sceneProvider:)`` instead.
    /// Use ``configure(with configuration:uiConfig:assetsBuilder:completion:)`` to pass in ``RemoteConfiguration``.
    @available(*, deprecated, message: """
            Deprecated, use ``Glia.startEngagement(engagementKind:in queueIds:features:sceneProvider:)`` instead.
            Use ``configure(with configuration:uiConfig:assetsBuilder:completion:)`` to pass in ``RemoteConfiguration``.
        """
    )
    public func startEngagementWithConfig(
        engagement: EngagementKind,
        in queueIds: [String],
        uiConfig: RemoteConfiguration,
        assetsBuilder: RemoteConfiguration.AssetsBuilder = .standard,
        features: Features = .all,
        sceneProvider: SceneProvider? = nil
    ) throws {
        loggerPhase.logger.oneTime.remoteLogger?.reportDeprecatedMethod(context: Self.self)
        // Store assetsBuilder and apply remote config to have ability to
        // apply them for Call Visualizer flow if integrator use
        // old `configure` method
        theme.apply(configuration: uiConfig, assetsBuilder: assetsBuilder)
        self.assetsBuilder = assetsBuilder

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

    /// Deprecated, use ``Glia.startEngagement(of kind:in queueIds:sceneProvider:)`` instead.
    /// Use ``configure(with configuration:uiConfig:theme:assetsBuilder:features:completion:)`` to pass in ``RemoteConfiguration``.
    @available(*, deprecated, message: """
            Deprecated, use ``Glia.startEngagement(of kind:in queueIds:features:sceneProvider:)`` instead.
            Use ``configure(with configuration:uiConfig:theme:assetsBuilder:features:completion:)`` to pass in ``RemoteConfiguration``.
        """
    )
    public func startEngagement(
        engagementKind: EngagementKind,
        in queueIds: [String],
        theme: Theme = Theme(),
        features: Features = .all,
        sceneProvider: SceneProvider? = nil
    ) throws {
        loggerPhase.logger.oneTime.remoteLogger?.reportDeprecatedMethod(context: Self.self)
        self.theme = theme
        try startEngagement(
            engagementKind: engagementKind,
            in: queueIds,
            features: features,
            sceneProvider: sceneProvider
        )
    }

    /// Deprecated, use ``Glia.startEngagement(of kind:in queueIds:sceneProvider:)`` instead.
    /// Use ``configure(with configuration:uiConfig:theme:assetsBuilder:features:completion:)`` to pass in ``Features``.
    public func startEngagement(
        engagementKind: EngagementKind,
        in queueIds: [String] = [],
        features: Features = .all,
        sceneProvider: SceneProvider? = nil
    ) throws {
        // Even though `configuration` is validated via non-deprecated
        // `Glia.startEngagement(engagementKind:in queueIds:sceneProvider:)`,
        // we need to validate it also here to make sure that `features` are assigned
        // only if `configuration` passes validation.
        guard self.configuration != nil else { throw GliaError.sdkIsNotConfigured }
        // We need to assign features to be used for restored engagement
        // during Direct ID authenticated flow.
        // Here we overwrite value that was set via `configure` method,
        // to preserve initial behaviour, when `configure` was not providing `features`.
        self.features = features
        try startEngagement(of: engagementKind, in: queueIds, sceneProvider: sceneProvider)
    }

    /// Deprecated, use ``configure(with configuration:theme:uiConfig:assetsBuilder:completion:)`` instead.
    @available(*, deprecated, message: """
            Deprecated, use ``configure(with configuration:theme:uiConfig:assetsBuilder:completion:)`` instead.
        """
    )
    public func configure(
        with configuration: Configuration,
        uiConfig: RemoteConfiguration? = nil,
        assetsBuilder: RemoteConfiguration.AssetsBuilder = .standard,
        completion: @escaping (Result<Void, Error>) -> Void
    ) throws {
        loggerPhase.logger.oneTime.remoteLogger?.reportDeprecatedMethod(context: Self.self)
        try configure(
            with: configuration,
            theme: Theme(),
            uiConfig: uiConfig,
            assetsBuilder: assetsBuilder,
            completion: completion
        )
    }
}

extension Glia.Authentication {
    @available(*, deprecated, message: "Use Glia.Authentication.authenticate(with:accessToken:completion:) instead.")
    public func authenticate(
        with idToken: IdToken,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        environment.log.oneTime.reportDeprecatedMethod(context: Self.self)
        self.authenticateWithIdToken(
            idToken,
            nil,
            completion
        )
    }
}
