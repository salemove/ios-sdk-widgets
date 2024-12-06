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
