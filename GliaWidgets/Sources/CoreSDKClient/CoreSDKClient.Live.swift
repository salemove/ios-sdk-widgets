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
            configureWithConfiguration: GliaCore.sharedInstance.configure(with:completion:), getVisitorInfo: {
                try await withCheckedThrowingContinuation { continuation in
                    GliaCore.sharedInstance.fetchVisitorInfo { result in
                        switch result {
                        case let .success(coreVisitorInfo):
                            let visitorInfo = coreVisitorInfo.asWidgetSdkVisitorInfo()
                            continuation.resume(returning: visitorInfo)
                        case let .failure(error):
                            continuation.resume(throwing: error)
                        }
                    }
                }
            },
            updateVisitorInfo: { visitorInfoUpdate in
                try await withCheckedThrowingContinuation { continuation in
                    GliaCore.sharedInstance.updateVisitorInfo(visitorInfoUpdate.asCoreSdkVisitorInfoUpdate()) { result in
                        switch result {
                        case let .success(success):
                            continuation.resume(returning: success)
                        case let .failure(error):
                            continuation.resume(throwing: error)
                        }
                    }
                }
            },
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
            queueForEngagement: { options, replaceExisting in
                try await withCheckedThrowingContinuation { continuation in
                    GliaCore.sharedInstance.queueForEngagement(
                        using: options,
                        replaceExisting: replaceExisting
                    ) { result in
                        switch result {
                        case let .success(queueTicket):
                            continuation.resume(returning: queueTicket)
                        case let .failure(error):
                            continuation.resume(throwing: error)
                        }
                    }
                }
            },
            sendMessagePreview: { message in
                try await withCheckedThrowingContinuation { continuation in
                    GliaCore.sharedInstance.sendMessagePreview(message: message) { success, error in
                        if let error = error {
                            continuation.resume(throwing: error)
                        } else {
                            continuation.resume(returning: success)
                        }
                    }
                }
            },
            sendMessageWithMessagePayload: { payload in
                try await withCheckedThrowingContinuation { continuation in
                    GliaCore.sharedInstance.send(messagePayload: payload) { result in
                        switch result {
                        case let .success(message):
                            continuation.resume(returning: message)
                        case let .failure(error):
                            continuation.resume(throwing: error)
                        }
                    }
                }
            },
            cancelQueueTicket: { queueTicket in
                try await withCheckedThrowingContinuation { continuation in
                    GliaCore.sharedInstance.cancel(queueTicket: queueTicket) { result, error in
                        if let error {
                            continuation.resume(throwing: error)
                            return
                        } else {
                            continuation.resume(returning: result)
                        }
                    }
                }
            },
            endEngagement: {
                try await withCheckedThrowingContinuation { continuation in
                    GliaCore.sharedInstance.endEngagement { success, error in
                        if let error = error {
                            continuation.resume(throwing: error)
                        } else {
                            continuation.resume(returning: success)
                        }
                    }
                }
            },
            requestEngagedOperator: {
                try await withCheckedThrowingContinuation { continuation in
                    GliaCore.sharedInstance.requestEngagedOperator { success, error in
                        if let error = error {
                            continuation.resume(throwing: error)
                        } else {
                            continuation.resume(returning: success)
                        }
                    }
                }
            },
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
        ),
        userNotificationCenterWillPresent: { center, notification, completionHandler in
            GliaCore.sharedInstance.pushNotifications.widgetsNotificationCenter(center, willPresent: notification, withCompletionHandler: completionHandler)
        },
        userNotificationCenterDidReceiveResponse: { center, response, completionHandler in
            GliaCore.sharedInstance.pushNotifications.widgetsNotificationCenter(center, didReceive: response, withCompletionHandler: completionHandler)
        }
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
