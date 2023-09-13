import Foundation
import GliaCoreSDK

extension Glia {
    /// Starts the engagement.
    ///
    /// - Parameters:
    ///   - engagementKind: Engagement media type.
    ///   - in: Queue identifiers
    ///   - theme: A custom theme to use with the engagement.
    ///   - visitorContext: Visitor context.
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
    public func startEngagement(
        engagementKind: EngagementKind,
        in queueIds: [String],
        theme: Theme = Theme(),
        features: Features = .all,
        sceneProvider: SceneProvider? = nil
    ) throws {
        // `interactor?.queueIds.isEmpty == false` statement is needed for integrators who uses old interface
        // and pass queue identifier through `configuration` function.
        guard !queueIds.isEmpty || interactor?.queueIds.isEmpty == false else { throw GliaError.startingEngagementWithNoQueueIdsIsNotAllowed }
        guard engagement == .none else { throw GliaError.engagementExists }
        guard let interactor = self.interactor else { throw GliaError.sdkIsNotConfigured }
        if let engagement = environment.coreSdk.getCurrentEngagement(),
            engagement.source == .callVisualizer {
            throw GliaError.callVisualizerEngagementExists
        }

        // This check is needed for integrators who uses old interface
        // and pass queue identifier through `configuration` function,
        // but would not pass queue ids in this method, so SDK would not override
        // existed queue id.
        if !queueIds.isEmpty {
            interactor.queueIds = queueIds
        }

        let viewFactory = ViewFactory(
            with: theme,
            messageRenderer: messageRenderer,
            environment: .init(
                data: environment.data,
                uuid: environment.uuid,
                gcd: environment.gcd,
                imageViewCache: environment.imageViewCache,
                timerProviding: environment.timerProviding,
                uiApplication: environment.uiApplication,
                uiScreen: environment.uiScreen
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

    func startRootCoordinator(
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
                uploadFileToEngagement: environment.coreSdk.uploadFileToEngagement,
                audioSession: environment.audioSession,
                uuid: environment.uuid,
                fileManager: environment.fileManager,
                data: environment.data,
                date: environment.date,
                gcd: environment.gcd,
                createThumbnailGenerator: environment.createThumbnailGenerator,
                createFileDownload: environment.createFileDownload,
                loadChatMessagesFromHistory: environment.loadChatMessagesFromHistory,
                timerProviding: environment.timerProviding,
                fetchSiteConfigurations: environment.coreSdk.fetchSiteConfigurations,
                getCurrentEngagement: environment.coreSdk.getCurrentEngagement,
                submitSurveyAnswer: environment.coreSdk.submitSurveyAnswer,
                uiApplication: environment.uiApplication,
                uiScreen: environment.uiScreen,
                uiDevice: environment.uiDevice,
                notificationCenter: environment.notificationCenter,
                fetchChatHistory: environment.coreSdk.fetchChatHistory,
                listQueues: environment.coreSdk.listQueues,
                sendSecureMessagePayload: environment.coreSdk.sendSecureMessagePayload,
                createFileUploader: environment.createFileUploader,
                createFileUploadListModel: environment.createFileUploadListModel,
                uploadSecureFile: environment.coreSdk.uploadSecureFile,
                getSecureUnreadMessageCount: environment.coreSdk.getSecureUnreadMessageCount,
                messagesWithUnreadCountLoaderScheduler: environment.messagesWithUnreadCountLoaderScheduler,
                secureMarkMessagesAsRead: environment.coreSdk.secureMarkMessagesAsRead,
                downloadSecureFile: environment.coreSdk.downloadSecureFile,
                isAuthenticated: { [environment] in
                    do {
                        return try environment.coreSdk.authentication(.forbiddenDuringEngagement).isAuthenticated
                    } catch {
                        debugPrint(#function, "isAuthenticated:", error.localizedDescription)
                        return false
                    }
                },
                startSocketObservation: environment.coreSdk.startSocketObservation,
                stopSocketObservation: environment.coreSdk.stopSocketObservation,
                pushNotifications: environment.coreSdk.pushNotifications,
                createSendMessagePayload: environment.coreSdk.createSendMessagePayload, 
                orientationManager: environment.orientationManager
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
