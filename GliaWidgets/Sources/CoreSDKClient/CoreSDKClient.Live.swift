import SalemoveSDK

extension CoreSdkClient {
    static let live: Self = {
        .init(
            pushNotifications: .live,
            createAppDelegate: Self.AppDelegate.live,
            clearSession: GliaCore.sharedInstance.clearSession,
            fetchVisitorInfo: GliaCore.sharedInstance.fetchVisitorInfo(_:),
            updateVisitorInfo: GliaCore.sharedInstance.updateVisitorInfo(_:completion:),
            sendSelectedOptionValue: GliaCore.sharedInstance.send(option:completion:),
            configureWithConfiguration: GliaCore.sharedInstance.configure(with:completion:),
            configureWithInteractor: GliaCore.sharedInstance.configure(interactor:),
            queueForEngagement: GliaCore.sharedInstance
                .queueForEngagement(queueID:visitorContext:shouldCloseAllQueues:mediaType:options:completion:),
            requestMediaUpgradeWithOffer: GliaCore.sharedInstance.requestMediaUpgrade(offer:completion:),
            sendMessagePreview: GliaCore.sharedInstance.sendMessagePreview(message:completion:),
            sendMessageWithAttachment: GliaCore.sharedInstance.send(message:attachment:completion:),
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
            sendSecureMessage: GliaCore.sharedInstance.secureConversations.send(secureMessage:attachment:queueIds:completion:),
            uploadSecureFile: { file, progress, completion in
                GliaCore
                    .sharedInstance
                    .secureConversations
                    .uploadFile(
                        file,
                        progress: { value in
                            print("progress value", value.fractionCompleted) },
                        completion: { result in
                            print("done uploading", result)
                        }
                    )
            }
        )
    }()
}

extension CoreSdkClient.PushNotifications {
    static let live = Self(
        applicationDidRegisterForRemoteNotificationsWithDeviceToken:
            GliaCore.sharedInstance.pushNotifications.application(_:didRegisterForRemoteNotificationsWithDeviceToken:)
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
