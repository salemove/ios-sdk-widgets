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
            configureWithConfiguration: GliaCore.sharedInstance.configure(with:),
            getVisitorInfo: {
                let coreVisitorInfo = try await GliaCore.sharedInstance.fetchVisitorInfo()
                return coreVisitorInfo.asWidgetSdkVisitorInfo()
            },
            updateVisitorInfo: { visitorInfoUpdate in
                try await GliaCore.sharedInstance.updateVisitorInfo(visitorInfoUpdate.asCoreSdkVisitorInfoUpdate())
            },
            configureWithInteractor: GliaCore.sharedInstance.configure(interactor:),
            getQueues: {
                try await GliaCore.sharedInstance.listQueues().map { $0.asWidgetSDKQueue() }
            },
            queueForEngagement: { options, replaceExisting in
                try await GliaCore.sharedInstance.queueForEngagement(
                    using: options,
                    replaceExisting: replaceExisting
                )
            },
            sendMessagePreview: { message in
                try await GliaCore.sharedInstance.sendMessagePreview(message: message)
            },
            sendMessageWithMessagePayload: { payload in
                try await GliaCore.sharedInstance.send(messagePayload: payload)
            },
            cancelQueueTicket: { queueTicket in
                try await GliaCore.sharedInstance.cancel(queueTicket: queueTicket)
            },
            endEngagement: {
                try await GliaCore.sharedInstance.endEngagement()
            },
            requestEngagedOperator: {
                try await GliaCore.sharedInstance.requestEngagedOperator()
            },
            uploadFileToEngagement: { file, progress in
                try await GliaCore.sharedInstance.uploadFileToEngagement(file, progress: progress)
            },
            fetchFile: { file, progress in
                try await GliaCore.sharedInstance.fetchFile(engagementFile: file, progress: progress)
            },
            getCurrentEngagement: GliaCore.sharedInstance.getCurrentEngagement,
            fetchSiteConfigurations: {
                try await GliaCore.sharedInstance.fetchSiteConfiguration()
            },
            submitSurveyAnswer: { answers, surveyId, engagementId in
                try await GliaCore.sharedInstance.submitSurveyAnswer(
                    answers,
                    surveyId: surveyId,
                    engagementId: engagementId
                )
            },
            authentication: GliaCore.sharedInstance.authentication,
            fetchChatHistory: {
                let messages = try await GliaCore.sharedInstance.fetchChatTranscript()
                return messages.map { ChatMessage(with: $0) }
            },
            requestVisitorCode: {
                try await GliaCore.sharedInstance.callVisualizer.requestVisitorCode()
            },
            startSocketObservation: GliaCore.sharedInstance.startSocketObservation,
            stopSocketObservation: GliaCore.sharedInstance.stopSocketObservation,
            createSendMessagePayload: CoreSdkClient.SendMessagePayload.init(content:attachment:),
            createLogger: { try Logger(GliaCore.sharedInstance.createLogger(externalParameters: $0)) },
            getCameraDeviceManageable: {
                try CameraDeviceManageableClient(
                    GliaCore.sharedInstance.cameraDeviceManageable()
                )
            },
            subscribeForQueuesUpdates: { queues in
                AsyncThrowingStream { continuation in
                    let task = Task {
                        do {
                            for try await coreQueue in GliaCore.sharedInstance.queueUpdatesStream(forQueues: queues) {
                                continuation.yield(coreQueue.asWidgetSDKQueue())
                            }
                            continuation.finish()
                        } catch {
                            continuation.finish(throwing: error)
                        }
                    }
                    continuation.onTermination = { _ in
                        task.cancel()
                    }
                }
            },
            configureLogLevel: GliaCore.sharedInstance.configureLogLevel(level:)
        )
    }()
}

extension CoreSdkClient.SecureConversations {
    static let live = Self(
        sendMessagePayload: { secureMessagePayload, queueIds in
            try await GliaCore.sharedInstance.secureConversations.send(
                secureMessagePayload: secureMessagePayload,
                queueIds: queueIds
            )
        },
        uploadFile: { file, progress in
            try await GliaCore.sharedInstance.secureConversations.uploadFile(file, progress: progress)
        },
        getUnreadMessageCount: {
            try await GliaCore.sharedInstance.secureConversations.getUnreadMessageCount()
        },
        markMessagesAsRead: {
            try await GliaCore.sharedInstance.secureConversations.markMessagesAsRead()
        },
        downloadFile: { file, progress in
            try await GliaCore.sharedInstance.secureConversations.downloadFile(file, progress: progress)
        },
        subscribeForUnreadMessageCount: GliaCore.sharedInstance.secureConversations.unreadMessageCountStream,
        observePendingStatus: GliaCore.sharedInstance.secureConversations.pendingSecureConversationStatusStream
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
            GliaCore.sharedInstance.pushNotifications.widgetsNotificationCenter(
                center,
                willPresent: notification,
                withCompletionHandler: completionHandler
            )
        },
        userNotificationCenterDidReceiveResponse: { center, response, completionHandler in
            GliaCore.sharedInstance.pushNotifications.widgetsNotificationCenter(
                center, didReceive: response,
                withCompletionHandler: completionHandler
            )
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
