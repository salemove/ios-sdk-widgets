@_spi(GliaWidgets) import GliaCoreSDK

extension CoreSdkClient {
    enum AsyncBridge {
        static func result<Value, Failure: Error>(
            _ operation: (@escaping (Result<Value, Failure>) -> Void) -> Void
        ) async throws -> Value {
            try await withCheckedThrowingContinuation { continuation in
                operation { result in
                    switch result {
                    case let .success(value):
                        continuation.resume(returning: value)
                    case let .failure(error):
                        continuation.resume(throwing: error)
                    }
                }
            }
        }

        static func pair<Value>(
            _ operation: (@escaping (Value, Error?) -> Void) -> Void
        ) async throws -> Value {
            try await withCheckedThrowingContinuation { continuation in
                operation { value, error in
                    if let error {
                        continuation.resume(throwing: error)
                    } else {
                        continuation.resume(returning: value)
                    }
                }
            }
        }

        static func optionalPair<Value>(
            nilError: Error,
            _ operation: (@escaping (Value?, Error?) -> Void) -> Void
        ) async throws -> Value {
            try await withCheckedThrowingContinuation { continuation in
                operation { value, error in
                    if let error {
                        continuation.resume(throwing: error)
                    } else if let value {
                        continuation.resume(returning: value)
                    } else {
                        continuation.resume(throwing: nilError)
                    }
                }
            }
        }

        static func cancellableResult<Value, Failure: Error>(
            _ operation: (@escaping (Result<Value, Failure>) -> Void) -> Cancellable
        ) async throws -> Value {
            let cancellableBox = CancellableBox()

            return try await withCheckedThrowingContinuation { continuation in
                cancellableBox.cancellable = operation { result in
                    withExtendedLifetime(cancellableBox.cancellable) {
                        switch result {
                        case let .success(value):
                            continuation.resume(returning: value)
                        case let .failure(error):
                            continuation.resume(throwing: error)
                        }
                    }
                    cancellableBox.cancellable = nil
                }
            }
        }
    }
}

private final class CancellableBox {
    var cancellable: CoreSdkClient.Cancellable?
}

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
                let coreVisitorInfo = try await AsyncBridge.result(GliaCore.sharedInstance.fetchVisitorInfo)
                return coreVisitorInfo.asWidgetSdkVisitorInfo()
            },
            updateVisitorInfo: { visitorInfoUpdate in
                try await AsyncBridge.result { completion in
                    GliaCore.sharedInstance.updateVisitorInfo(
                        visitorInfoUpdate.asCoreSdkVisitorInfoUpdate(),
                        completion: completion
                    )
                }
            },
            configureWithInteractor: GliaCore.sharedInstance.configure(interactor:),
            getQueues: {
                try await AsyncBridge.optionalPair(
                    nilError: GliaError.internalError
                ) { completion in
                    GliaCore.sharedInstance.listQueues { coreQueues, error in
                        completion(coreQueues?.map { $0.asWidgetSDKQueue() }, error)
                    }
                }
            },
            queueForEngagement: { options, replaceExisting in
                try await AsyncBridge.result { completion in
                    GliaCore.sharedInstance.queueForEngagement(
                        using: options,
                        replaceExisting: replaceExisting
                    ) { completion($0) }
                }
            },
            sendMessagePreview: { message in
                try await AsyncBridge.pair { completion in
                    GliaCore.sharedInstance.sendMessagePreview(message: message) { success, error in
                        completion(success, error)
                    }
                }
            },
            sendMessageWithMessagePayload: { payload in
                try await AsyncBridge.result { completion in
                    GliaCore.sharedInstance.send(messagePayload: payload) { completion($0) }
                }
            },
            cancelQueueTicket: { queueTicket in
                try await AsyncBridge.pair { completion in
                    GliaCore.sharedInstance.cancel(queueTicket: queueTicket) { result, error in
                        completion(result, error)
                    }
                }
            },
            endEngagement: {
                try await AsyncBridge.pair { completion in
                    GliaCore.sharedInstance.endEngagement { success, error in
                        completion(success, error)
                    }
                }
            },
            requestEngagedOperator: {
                try await AsyncBridge.pair { completion in
                    GliaCore.sharedInstance.requestEngagedOperator { success, error in
                        completion(success, error)
                    }
                }
            },
            uploadFileToEngagement: GliaCore.sharedInstance.uploadFileToEngagement(_:progress:completion:),
            fetchFile: { file, progress in
                try await AsyncBridge.optionalPair(
                    nilError: FileError.fileUnavailable
                ) { completion in
                    GliaCore.sharedInstance.fetchFile(engagementFile: file, progress: progress) { fileInformation, error in
                        completion(fileInformation, error)
                    }
                }
            },
            getCurrentEngagement: GliaCore.sharedInstance.getCurrentEngagement,
            fetchSiteConfigurations: {
                try await AsyncBridge.result(GliaCore.sharedInstance.fetchSiteConfiguration)
            },
            submitSurveyAnswer: { answers, surveyId, engagementId in
                try await AsyncBridge.result { completion in
                    GliaCore.sharedInstance.submitSurveyAnswer(answers, surveyId: surveyId, engagementId: engagementId) { result in
                        completion(result)
                    }
                }
            },
            authentication: GliaCore.sharedInstance.authentication,
            fetchChatHistory: {
                let messages = try await AsyncBridge.result(GliaCore.sharedInstance.fetchChatTranscript)
                return messages.map { ChatMessage(with: $0) }
            },
            requestVisitorCode: {
                try await AsyncBridge.cancellableResult(
                    GliaCore.sharedInstance.callVisualizer.requestVisitorCode
                )
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
        sendMessagePayload: { secureMessagePayload, queueIds in
            try await CoreSdkClient.AsyncBridge.cancellableResult { completion in
                GliaCore.sharedInstance.secureConversations.send(
                    secureMessagePayload: secureMessagePayload,
                    queueIds: queueIds
                ) { completion($0) }
            }
        },
        uploadFile: GliaCore.sharedInstance.secureConversations.uploadFile(_:progress:completion:),
        getUnreadMessageCount: {
            try await CoreSdkClient.AsyncBridge.result(
                GliaCore.sharedInstance.secureConversations.getUnreadMessageCount
            )
        },
        markMessagesAsRead: {
            try await CoreSdkClient.AsyncBridge.cancellableResult(
                GliaCore.sharedInstance.secureConversations.markMessagesAsRead
            )
        },
        downloadFile: { file, progress in
            try await CoreSdkClient.AsyncBridge.cancellableResult { completion in
                GliaCore.sharedInstance.secureConversations.downloadFile(file, progress: progress) { completion($0) }
            }
        },
        subscribeForUnreadMessageCount: GliaCore.sharedInstance.secureConversations.subscribeToUnreadMessageCount(completion:),
        unsubscribeFromUnreadMessageCount: GliaCore.sharedInstance.secureConversations.unsubscribeFromUnreadMessageCount,
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
