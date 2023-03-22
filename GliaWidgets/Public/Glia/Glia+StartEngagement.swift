import Foundation
import SalemoveSDK

extension Glia {
    /// Starts the engagement.
    ///
    /// - Parameters:
    ///   - engagementKind: Engagement media type.
    ///   - theme: A custom theme to use with the engagement.
    ///   - visitorContext: Visitor context.
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
    public func startEngagement(
        engagementKind: EngagementKind,
        theme: Theme = Theme(),
        features: Features = .all,
        sceneProvider: SceneProvider? = nil
    ) throws {
        guard engagement == .none else { throw GliaError.engagementExists }
        guard let interactor = self.interactor else { throw GliaError.sdkIsNotConfigured }

        let viewFactory = ViewFactory(
            with: theme,
            messageRenderer: messageRenderer,
            environment: .init(
                data: environment.data,
                uuid: environment.uuid,
                gcd: environment.gcd,
                imageViewCache: environment.imageViewCache,
                timerProviding: environment.timerProviding,
                uiApplication: environment.uiApplication
            )
        )
        startRootCoordinator(
            with: interactor,
            viewFactory: viewFactory,
            sceneProvider: sceneProvider,
            engagementKind: engagementKind,
            features: features
        )
    }

    /// Starts the engagement.
    ///
    /// - Parameters:
    ///   - engagementKind: Engagement media type.
    ///   - configuration: Engagement configuration.
    ///   - queueID: Queue identifier.
    ///   - visitorContext: Visitor context.
    ///   - theme: A custom theme to use with the engagement.
    ///   - sceneProvider: Used to provide `UIWindowScene` to the framework. Defaults to the first active foreground scene.
    ///
    /// - throws:
    ///   - `SalemoveSDK.ConfigurationError.invalidSite`
    ///   - `SalemoveSDK.ConfigurationError.invalidEnvironment`
    ///   - `SalemoveSDK.ConfigurationError.invalidRegionEndpoint`
    ///   - `SalemoveSDK.ConfigurationError.invalidSiteApiKey`
    ///   - `SalemoveSDK.ConfigurationError.invalidAppToken`
    ///   - `GliaError.engagementExists`
    ///
    public func start(
        _ engagementKind: EngagementKind,
        configuration: Configuration,
        queueID: String,
        visitorContext: VisitorContext?, // GliaCoreSDK.VisitorContext
        theme: Theme = Theme(),
        features: Features = .all,
        sceneProvider: SceneProvider? = nil
    ) throws {
        try configure(
            with: configuration,
            queueId: queueID,
            visitorContext: visitorContext
        ) { [weak self] in
            self?.setChatMessageRenderer(messageRenderer: .webRenderer)
            do {
                try self?.startEngagement(
                    engagementKind: engagementKind,
                    theme: theme,
                    features: features,
                    sceneProvider: sceneProvider
                )
            } catch {
                print("Engagement has not been started. Error='\(error)'.")
            }
        }
    }

    // MARK: - Private

    private func startRootCoordinator(
        with interactor: Interactor,
        viewFactory: ViewFactory,
        sceneProvider: SceneProvider?,
        engagementKind: EngagementKind,
        features: Features
    ) {
        rootCoordinator = self.environment.rootCoordinator(
            interactor: interactor,
            viewFactory: viewFactory,
            sceneProvider: sceneProvider,
            engagementKind: engagementKind,
            screenShareHandler: environment.screenShareHandler,
            features: features,
            environment: .init(
                fetchFile: environment.coreSdk.fetchFile,
                sendSelectedOptionValue: environment.coreSdk.sendSelectedOptionValue,
                uploadFileToEngagement: environment.coreSdk.uploadFileToEngagement,
                audioSession: environment.audioSession,
                uuid: environment.uuid,
                fileManager: environment.fileManager,
                data: environment.data,
                date: environment.date,
                gcd: environment.gcd,
                localFileThumbnailQueue: environment.localFileThumbnailQueue,
                uiImage: environment.uiImage,
                createFileDownload: environment.createFileDownload,
                loadChatMessagesFromHistory: environment.loadChatMessagesFromHistory,
                timerProviding: environment.timerProviding,
                fetchSiteConfigurations: environment.coreSdk.fetchSiteConfigurations,
                getCurrentEngagement: environment.coreSdk.getCurrentEngagement,
                submitSurveyAnswer: environment.coreSdk.submitSurveyAnswer,
                uiApplication: environment.uiApplication,
                fetchChatHistory: environment.coreSdk.fetchChatHistory,
                listQueues: environment.coreSdk.listQueues,
                sendSecureMessage: environment.coreSdk.sendSecureMessage,
                createFileUploader: environment.createFileUploader,
                createFileUploadListModel: environment.createFileUploadListModel,
                uploadSecureFile: environment.coreSdk.uploadSecureFile,
                getSecureUnreadMessageCount: environment.coreSdk.getSecureUnreadMessageCount,
                messagesWithUnreadCountLoaderScheduler: environment.messagesWithUnreadCountLoaderScheduler,
                secureMarkMessagesAsRead: environment.coreSdk.secureMarkMessagesAsRead,
                downloadSecureFile: environment.coreSdk.downloadSecureFile
            )
        )
        rootCoordinator?.delegate = { [weak self] event in
            self?.handleCoordinatorEvent(event)
        }
        rootCoordinator?.start()
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
