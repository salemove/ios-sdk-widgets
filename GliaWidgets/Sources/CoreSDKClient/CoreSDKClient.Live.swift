@_spi(GliaWidgets) import GliaCoreSDK

extension CoreSdkClient {
    static let live: Self = {
        .init(
            pushNotifications: .live,
            createAppDelegate: Self.AppDelegate.live,
            clearSession: GliaCore.sharedInstance.clearSession,
            localeProvider: .init(getRemoteString: GliaCore.sharedInstance.localeProvider.getRemoteString(_:)),
            fetchVisitorInfo: GliaCore.sharedInstance.fetchVisitorInfo(_:),
            updateVisitorInfo: GliaCore.sharedInstance.updateVisitorInfo(_:completion:),
            configureWithConfiguration: GliaCore.sharedInstance.configure(with:completion:),
            configureWithInteractor: GliaCore.sharedInstance.configure(interactor:),
            listQueues: GliaCore.sharedInstance.listQueues(completion:),
            queueForEngagement: { options, completion in
                let options = QueueForEngagementOptions(
                    queueIds: options.queueIds,
                    visitorContext: options.visitorContext,
                    shouldCloseAllQueues: options.shouldCloseAllQueues,
                    mediaType: options.mediaType,
                    engagementOptions: options.engagementOptions
                )
                GliaCore.sharedInstance.queueForEngagement(using: options, completion: completion)
            },
            requestMediaUpgradeWithOffer: GliaCore.sharedInstance.requestMediaUpgrade(offer:completion:),
            sendMessagePreview: GliaCore.sharedInstance.sendMessagePreview(message:completion:),
            sendMessageWithMessagePayload: GliaCore.sharedInstance.send(messagePayload:completion:),
            cancelQueueTicket: GliaCore.sharedInstance.cancel(queueTicket:completion:),
            endEngagement: GliaCore.sharedInstance.endEngagement(completion:),
            requestEngagedOperator: GliaCore.sharedInstance.requestEngagedOperator(completion:),
            uploadFileToEngagement: GliaCore.sharedInstance.uploadFileToEngagement(_:progress:completion:),
            fetchFile: GliaCore.sharedInstance.fetchFile(engagementFile:progress:completion:),
            getCurrentEngagement: GliaCore.sharedInstance.getCurrentEngagement,
            fetchSiteConfigurations: GliaCore.sharedInstance.fetchSiteConfiguration(_:),
            submitSurveyAnswer: GliaCore.sharedInstance.submitSurveyAnswer(_:surveyId:engagementId:completion:),
            authentication: GliaCore.sharedInstance.authentication,
            fetchChatHistory: { completion in
                GliaCore.sharedInstance.fetchChatTranscript { result in
                    switch result {
                    case let .success(messages):
                        completion(
                            .success(messages.map { ChatMessage(with: $0) })
                        )
                    case let .failure(error):
                        completion(.failure(error))
                    }
                }
            },
            requestVisitorCode: GliaCore.sharedInstance.callVisualizer.requestVisitorCode(completion:),
            sendSecureMessagePayload: GliaCore.sharedInstance.secureConversations.send(secureMessagePayload:queueIds:completion:),
            uploadSecureFile: GliaCore.sharedInstance.secureConversations.uploadFile(_:progress:completion:),
            getSecureUnreadMessageCount: GliaCore.sharedInstance.secureConversations.getUnreadMessageCount(completion:),
            secureMarkMessagesAsRead: GliaCore.sharedInstance.secureConversations.markMessagesAsRead(completion:),
            downloadSecureFile: GliaCore.sharedInstance.secureConversations.downloadFile(_:progress:completion:),
            startSocketObservation: GliaCore.sharedInstance.startSocketObservation,
            stopSocketObservation: GliaCore.sharedInstance.stopSocketObservation,
            createSendMessagePayload: CoreSdkClient.SendMessagePayload.init(content:attachment:),
            createLogger: { try Logger(GliaCore.sharedInstance.createLogger(externalParameters: $0)) },
            getCameraDeviceManageable: {
                try CameraDeviceManageableClient(
                    GliaCore.sharedInstance.cameraDeviceManageable()
                )
            }
        )
    }()
}

extension CoreSdkClient.PushNotifications {
    static let live = Self(
        applicationDidRegisterForRemoteNotificationsWithDeviceToken:
            GliaCore.sharedInstance.pushNotifications.application(_:didRegisterForRemoteNotificationsWithDeviceToken:),
        setPushHandler: { GliaCore.sharedInstance.pushNotifications.handler = $0 },
        pushHandler: { GliaCore.sharedInstance.pushNotifications.handler }
    )
}

extension CoreSdkClient.AppDelegate {
    static func live() -> Self {
        let gliaCoreAppDelegate = GliaCoreAppDelegate()
        return .init(
            applicationDidFinishLaunchingWithOptions: gliaCoreAppDelegate.application(_:didFinishLaunchingWithOptions:),
            applicationDidBecomeActive: gliaCoreAppDelegate.applicationDidBecomeActive
        )
    }
}

extension CoreSdkClient.CameraDeviceManageableClient {
    init(_ live: CameraDeviceManageable) {
        self.cameraDevices = { live.cameraDevices() }
        self.currentCameraDevice = { live.currentCameraDevice() }
        self.setCameraDevice = { live.setCameraDevice($0) }
    }
}
