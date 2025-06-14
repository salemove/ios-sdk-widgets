@_spi(GliaWidgets) import GliaCoreSDK

extension CoreSdkClient {
    static let live: Self = {
        .init(
            pushNotifications: .live,
            liveObservation: .live,
            secureConversations: .live,
            createAppDelegate: Self.AppDelegate.live,
            clearSession: GliaCore.sharedInstance.clearSession,
            localeProvider: .init(getRemoteString: GliaCore.sharedInstance.localeProvider.getRemoteString(_:)),
            getVisitorInfo: { completion in
                GliaCore.sharedInstance.fetchVisitorInfo { result in
                    switch result {
                    case let .success(coreVisitorInfo):
                        let visitorInfo = coreVisitorInfo.asWidgetSdkVisitorInfo()
                        completion(.success(visitorInfo))
                    case let .failure(error):
                        completion(.failure(error))
                    }
                }
            },
            getVisitorInfoDeprecated: GliaCore.sharedInstance.fetchVisitorInfo(_:),
            updateVisitorInfo: { visitorInfoUpdate, completion in
                let coreSdkVisitorInfoUpdate = visitorInfoUpdate.asCoreSdkVisitorInfoUpdate()
                GliaCore.sharedInstance.updateVisitorInfo(coreSdkVisitorInfoUpdate, completion: completion)
            },
            updateVisitorInfoDeprecated: GliaCore.sharedInstance.updateVisitorInfo(_:completion:),
            configureWithConfiguration: GliaCore.sharedInstance.configure(with:completion:),
            configureWithInteractor: GliaCore.sharedInstance.configure(interactor:),
            getQueues: { completion in
                GliaCore.sharedInstance.listQueues { coreQueues, error in
                    if let error {
                        completion(.failure(error))
                        return
                    }

                    if let coreQueues {
                        let queues = coreQueues.map { $0.asWidgetSDKQueue() }
                        completion(.success(queues))
                        return
                    }
                    completion(.failure(GliaError.internalError))
                }
            },
            queueForEngagement: { options, replaceExisting, completion in
                let options = QueueForEngagementOptions(
                    queueIds: options.queueIds,
                    visitorContext: options.visitorContext,
                    shouldCloseAllQueues: options.shouldCloseAllQueues,
                    mediaType: options.mediaType,
                    engagementOptions: options.engagementOptions
                )
                GliaCore.sharedInstance.queueForEngagement(
                    using: options, replaceExisting: replaceExisting, completion: completion
                )
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
            startSocketObservation: GliaCore.sharedInstance.startSocketObservation,
            stopSocketObservation: GliaCore.sharedInstance.stopSocketObservation,
            createSendMessagePayload: CoreSdkClient.SendMessagePayload.init(content:attachment:),
            createLogger: { try Logger(GliaCore.sharedInstance.createLogger(externalParameters: $0)) },
            getCameraDeviceManageable: {
                try CameraDeviceManageableClient(
                    GliaCore.sharedInstance.cameraDeviceManageable()
                )
            },
            subscribeForQueuesUpdates: { queues, completion in
                GliaCore.sharedInstance.subscribeForQueuesUpdates(forQueues: queues) { result in
                    switch result {
                    case let .success(coreQueue):
                        let queue = coreQueue.asWidgetSDKQueue()
                        completion(.success(queue))
                    case let .failure(error):
                        completion(.failure(error))
                    }
                }
            },
            unsubscribeFromUpdates: GliaCore.sharedInstance.unsubscribeFromUpdates(queueCallbackId:onError:),
            configureLogLevel: GliaCore.sharedInstance.configureLogLevel(level:)
        )
    }()
}

extension CoreSdkClient.SecureConversations {
    static let live = Self(
        sendMessagePayload: GliaCore.sharedInstance.secureConversations.send(secureMessagePayload:queueIds:completion:),
        uploadFile: GliaCore.sharedInstance.secureConversations.uploadFile(_:progress:completion:),
        getUnreadMessageCount: GliaCore.sharedInstance.secureConversations.getUnreadMessageCount(completion:),
        markMessagesAsRead: GliaCore.sharedInstance.secureConversations.markMessagesAsRead(completion:),
        downloadFile: GliaCore.sharedInstance.secureConversations.downloadFile(_:progress:completion:),
        subscribeForUnreadMessageCount: GliaCore.sharedInstance.secureConversations.subscribeToUnreadMessageCount(completion:),
        unsubscribeFromUnreadMessageCount: GliaCore.sharedInstance.secureConversations.unsubscribeFromUnreadMessageCount,
        pendingStatus: GliaCore.sharedInstance.secureConversations.pendingSecureConversationStatus,
        observePendingStatus: GliaCore.sharedInstance.secureConversations.subscribeToPendingSecureConversationStatus,
        unsubscribeFromPendingStatus: { GliaCore.sharedInstance.secureConversations.unsubscribeFromPendingSecureConversationStatus($0) }
    )
}

extension CoreSdkClient.LiveObservation {
    static let live = Self(
        pause: {
            GliaCore.sharedInstance.liveObservation.pause()
        },
        resume: {
            GliaCore.sharedInstance.liveObservation.resume()
        }
    )
}

extension CoreSdkClient.PushNotifications {
    static let live = Self(
        applicationDidRegisterForRemoteNotificationsWithDeviceToken: { application, token in
            GliaCore.sharedInstance.pushNotifications.application(
                application,
                didRegisterForRemoteNotificationsWithDeviceToken: token
            )
        },
        applicationDidFailToRegisterForRemoteNotificationsWithError: { application, error in
            GliaCore.sharedInstance.pushNotifications.application(
                application,
                didFailToRegisterForRemoteNotificationsWithError: error
            )
        },
        setPushHandler: { GliaCore.sharedInstance.pushNotifications.handler = $0 },
        pushHandler: { GliaCore.sharedInstance.pushNotifications.handler },
        subscribeTo: GliaCore.sharedInstance.pushNotifications.subscribeTo(_:),
        actions: .init(
            setSecureMessageAction: { GliaCore.sharedInstance.pushNotificationsActionProcessor.secureMessagePushNotificationAction = $0 },
            secureMessageAction: { GliaCore.sharedInstance.pushNotificationsActionProcessor.secureMessagePushNotificationAction }
        )
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
