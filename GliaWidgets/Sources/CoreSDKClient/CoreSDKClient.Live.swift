@_spi(GliaWidgets) internal import GliaCoreSDK

extension CoreSdkClient {
    static let live: Self = {
        let core = GliaCore.sharedInstanceForWidgets
        return .init(
            pushNotifications: .live,
            liveObservation: .live,
            secureConversations: .live,
            clearSession: core.clearSessionForWidgets,
            localeProvider: .init(getRemoteString: core.localeProvider.getRemoteStringForWidgets(_:)),
            configureWithConfiguration: core.configureForWidgets(with:),
            getVisitorInfo: {
                let coreVisitorInfo = try await core.fetchVisitorInfoForWidgets()
                return coreVisitorInfo.asWidgetSdkVisitorInfo()
            },
            updateVisitorInfo: { visitorInfoUpdate in
                try await core.updateVisitorInfoForWidgets(visitorInfoUpdate.asCoreSdkVisitorInfoUpdate())
            },
            configureWithInteractor: core.configureForWidgets(interactor:),
            getQueues: {
                try await core.listQueuesForWidgets().map { $0.asWidgetSDKQueue() }
            },
            queueForEngagement: { options, replaceExisting in
                try await core.queueForEngagementForWidgets(
                    using: options,
                    replaceExisting: replaceExisting
                )
            },
            sendMessagePreview: { message in
                try await core.sendMessagePreviewForWidgets(message: message)
            },
            sendMessageWithMessagePayload: { payload in
                try await core.sendForWidgets(messagePayload: payload)
            },
            cancelQueueTicket: { queueTicket in
                try await core.cancelForWidgets(queueTicket: queueTicket)
            },
            endEngagement: {
                try await core.endEngagementForWidgets()
            },
            requestEngagedOperator: {
                try await core.requestEngagedOperatorForWidgets()
            },
            uploadFileToEngagement: { file, progress in
                try await core.uploadFileToEngagementForWidgets(file, progress: progress)
            },
            fetchFile: { file, progress in
                let fileData = try await core.fetchFileForWidgets(engagementFile: file, progress: progress)
                return .init(data: fileData.data)
            },
            getCurrentEngagement: core.getCurrentEngagementForWidgets,
            fetchSiteConfigurations: {
                try await core.fetchSiteConfigurationForWidgets()
            },
            submitSurveyAnswer: { answers, surveyId, engagementId in
                try await core.submitSurveyAnswerForWidgets(
                    answers,
                    surveyId: surveyId,
                    engagementId: engagementId
                )
            },
            authentication: core.authenticationForWidgets(with:),
            fetchChatHistory: {
                let messages = try await core.fetchChatTranscriptForWidgets()
                return messages.map { ChatMessage(with: $0) }
            },
            requestVisitorCode: {
                try await core.callVisualizer.requestVisitorCodeForWidgets()
            },
            startSocketObservation: core.startSocketObservationForWidgets,
            stopSocketObservation: core.stopSocketObservationForWidgets,
            createSendMessagePayload: CoreSdkClient.SendMessagePayload.init(content:attachment:),
            createLogger: { try Logger(core.createLoggerForWidgets(externalParameters: $0)) },
            getCameraDeviceManageable: {
                try CameraDeviceManageableClient(core.cameraDeviceManageableForWidgets())
            },
            queueUpdatesStream: { queues in
                AsyncThrowingStream { continuation in
                    let task = Task {
                        do {
                            for try await coreQueue in core.queueUpdatesStreamForWidgets(forQueues: queues) {
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
            configureLogLevel: { level in
                core.configureLogLevelForWidgets(level.coreLevel)
            }
        )
    }()
}

extension LogLevel {
    var coreLevel: GliaCoreSDK.LogLevel {
        switch self {
        case .none: return .none
        case .error: return .error
        case .warning: return .warning
        case .info: return .info
        case .debug: return .debug
        }
    }
}

extension CoreSdkClient.SecureConversations {
    private static var core: GliaCore { .sharedInstanceForWidgets }

    static let live = Self(
        sendMessagePayload: { secureMessagePayload, queueIds in
            try await core.secureConversations.sendForWidgets(
                payload: secureMessagePayload,
                queueIds: queueIds
            )
        },
        uploadFile: { file, progress in
            try await core.secureConversations.uploadFileForWidgets(file, progress: progress)
        },
        getUnreadMessageCount: {
            try await core.secureConversations.getUnreadMessageCountForWidgets()
        },
        markMessagesAsRead: {
            try await core.secureConversations.markMessagesAsReadForWidgets()
        },
        downloadFile: { file, progress in
            let fileData = try await core.secureConversations.downloadFileForWidgets(file, progress: progress)
            return .init(data: fileData.data)
        },
        unreadMessageCountStream: core.secureConversations.unreadMessageCountStreamForWidgets,
        pendingSecureConversationStatusStream: core.secureConversations.pendingSecureConversationStatusStreamForWidgets
    )
}

extension CoreSdkClient.LiveObservation {
    static let live = Self(
        pause: {
            GliaCore.sharedInstanceForWidgets.liveObservation.pauseForWidgets()
        },
        resume: {
            GliaCore.sharedInstanceForWidgets.liveObservation.resumeForWidgets()
        }
    )
}

extension CoreSdkClient.PushNotifications {
    private static var core: GliaCore { .sharedInstanceForWidgets }

    static let live = Self(
        applicationDidRegisterForRemoteNotificationsWithDeviceToken: { application, token in
            core.pushNotifications.applicationForWidgets(
                application,
                didRegisterForRemoteNotificationsWithDeviceToken: token
            )
        },
        applicationDidFailToRegisterForRemoteNotificationsWithError: { application, error in
            core.pushNotifications.applicationForWidgets(
                application,
                didFailToRegisterForRemoteNotificationsWithError: error
            )
        },
        setPushHandler: { handler in
            core.pushNotifications.handlerForWidgets = handler.map { handler in
                { handler(Push(corePush: $0)) }
            }
        },
        subscribeTo: { types in
            core.pushNotifications.subscribeForWidgets(types.map(\.coreType))
        },
        actions: .init(
            setSecureMessageAction: {
                core.pushNotificationsActionProcessor.secureMessagePushNotificationActionForWidgets = $0
            },
            secureMessageAction: {
                core.pushNotificationsActionProcessor.secureMessagePushNotificationActionForWidgets
            }
        ),
        userNotificationCenterWillPresent: { center, notification, completionHandler in
            core.pushNotifications.widgetsNotificationCenterForWidgets(
                center,
                willPresent: notification,
                withCompletionHandler: completionHandler
            )
        },
        userNotificationCenterDidReceiveResponse: { center, response, completionHandler in
            core.pushNotifications.widgetsNotificationCenterForWidgets(
                center, didReceive: response,
                withCompletionHandler: completionHandler
            )
        }
    )
}

extension CoreSdkClient.CameraDeviceManageableClient {
    init(_ live: GliaCoreSDK.CameraDeviceManageable) {
        self.cameraDevices = { live.cameraDevices() }
        self.currentCameraDevice = { live.currentCameraDevice() }
        self.setCameraDevice = { live.setCameraDevice($0) }
    }
}
