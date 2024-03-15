import Foundation
import GliaCoreSDK

extension Glia {
    /// Starts the engagement.
    ///
    /// - Parameters:
    ///   - engagementKind: Engagement media type.
    ///   - in: Queue identifiers
    ///   - features: Set of features to be enabled in the SDK.
    ///   - sceneProvider: Used to provide `UIWindowScene` to the framework. Defaults to
    ///     the first active foreground scene.
    ///
    /// - throws:
    ///   - `GliaCoreSDK.ConfigurationError.invalidSite`
    ///   - `GliaCoreSDK.ConfigurationError.invalidEnvironment`
    ///   - `GliaError.engagementExists
    ///   - `GliaError.sdkIsNotConfigured`
    ///
    /// - Important: Note, that `configure(with:uiConfig:assetsBuilder:completion:)` must be called
    ///   initially prior to this method, because `GliaError.sdkIsNotConfigured` will occur otherwise.
    ///
    public func startEngagement(
        engagementKind: EngagementKind,
        in queueIds: [String],
        features: Features = .all,
        sceneProvider: SceneProvider? = nil
    ) throws {
        let trimmedQueueIds = queueIds
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
        guard !trimmedQueueIds.isEmpty else { throw GliaError.startingEngagementWithNoQueueIdsIsNotAllowed }
        guard engagement == .none else { throw GliaError.engagementExists }
        guard let configuration = self.configuration else { throw GliaError.sdkIsNotConfigured }
        if let engagement = environment.coreSdk.getCurrentEngagement(),
            engagement.source == .callVisualizer {
            throw GliaError.callVisualizerEngagementExists
        }

        // Creates interactor instance
        let createdInteractor = setupInteractor(
            configuration: configuration,
            queueIds: trimmedQueueIds
        )

        // Apply company name to theme and get the modified theme
        let modifiedTheme = applyCompanyName(using: configuration, theme: theme)

        let viewFactory = ViewFactory(
            with: modifiedTheme,
            messageRenderer: messageRenderer,
            environment: .init(
                data: environment.data,
                uuid: environment.uuid,
                gcd: environment.gcd,
                imageViewCache: environment.imageViewCache,
                timerProviding: environment.timerProviding,
                uiApplication: environment.uiApplication,
                uiScreen: environment.uiScreen,
                log: loggerPhase.logger
            )
        )

        startRootCoordinator(
            with: createdInteractor,
            viewFactory: viewFactory,
            sceneProvider: sceneProvider,
            engagementKind: engagementKind,
            features: features
        )
    }

    func companyName(
        using configuration: Configuration,
        themeCompanyName: String?
    ) -> String {
        let companyNameStringKey = "general.company_name"

        // Company name has been set on the custom locale and is not empty.
        if let remoteCompanyName = stringProvidingPhase(companyNameStringKey),
            !remoteCompanyName.isEmpty {
            return remoteCompanyName
        }
        // As the default value in the theme is not empty, it means that
        // the integrator has set a value on the theme itself. Return that
        // same value.
        else if let themeCompanyName, !themeCompanyName.isEmpty {
            return themeCompanyName
        }
        // Integrator has not set a company name in the custom locale,
        // but has set it on the configuration.
        else if !configuration.companyName.isEmpty {
            return configuration.companyName
        }
        // Integrator has not set a company name anywhere, use the default.
        else {
            // This will return the fallback value every time, because we have
            // already determined that the remote string is empty.
            return Localization.General.companyNameLocalFallbackOnly
        }
    }

    private func applyCompanyName(using configuration: Configuration, theme: Theme) -> Theme {
        theme.chat.connect.queue.firstText = companyName(
            using: configuration,
            themeCompanyName: theme.chat.connect.queue.firstText
        )
        theme.call.connect.queue.firstText = companyName(
            using: configuration,
            themeCompanyName: theme.call.connect.queue.firstText
        )
        return theme
    }

    func startRootCoordinator(
        with interactor: Interactor,
        viewFactory: ViewFactory,
        sceneProvider: SceneProvider?,
        engagementKind: EngagementKind,
        features: Features,
        maximize: Bool = true
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
                orientationManager: environment.orientationManager,
                proximityManager: environment.proximityManager,
                log: loggerPhase.logger,
                snackBar: environment.snackBar,
                operatorRequestHandlerService: operatorRequestHandlerService,
                maximumUploads: { self.maximumUploads }
            )
        )
        rootCoordinator?.delegate = { [weak self] event in
            self?.handleCoordinatorEvent(event)
        }
        rootCoordinator?.start(maximize: maximize)
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
