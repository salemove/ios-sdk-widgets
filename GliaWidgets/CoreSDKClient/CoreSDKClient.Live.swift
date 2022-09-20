import SalemoveSDK

extension CoreSdkClient {
    static let live: Self = {
        .init(
            pushNotifications: .live,
            createAppDelegate: Self.AppDelegate.live,
            clearSession: Salemove.sharedInstance.clearSession,
            fetchVisitorInfo: Salemove.sharedInstance.fetchVisitorInfo(_:),
            updateVisitorInfo: Salemove.sharedInstance.updateVisitorInfo(_:completion:),
            sendSelectedOptionValue: Salemove.sharedInstance.send(option:completion:),
            configureWithConfiguration: Salemove.sharedInstance.configure(with:completion:),
            configureWithInteractor: Salemove.sharedInstance.configure(interactor:),
            queueForEngagement: Salemove.sharedInstance
                .queueForEngagement(queueID:visitorContext:shouldCloseAllQueues:mediaType:options:completion:),
            requestMediaUpgradeWithOffer: Salemove.sharedInstance.requestMediaUpgrade(offer:completion:),
            sendMessagePreview: Salemove.sharedInstance.sendMessagePreview(message:completion:),
            sendMessageWithAttachment: Salemove.sharedInstance.send(message:attachment:completion:),
            cancelQueueTicket: Salemove.sharedInstance.cancel(queueTicket:completion:),
            endEngagement: Salemove.sharedInstance.endEngagement(completion:),
            requestEngagedOperator: Salemove.sharedInstance.requestEngagedOperator(completion:),
            uploadFileToEngagement: Salemove.sharedInstance.uploadFileToEngagement(_:progress:completion:),
            fetchFile: Salemove.sharedInstance.fetchFile(engagementFile:progress:completion:),
            getCurrentEngagement: Salemove.sharedInstance.getCurrentEngagement,
            fetchSiteConfigurations: Salemove.sharedInstance.fetchSiteConfiguration(_:),
            submitSurveyAnswer: Salemove.sharedInstance.submitSurveyAnswer(_:surveyId:engagementId:completion:),
            authentication: Salemove.sharedInstance.authentication,
            fetchChatHistory: Salemove.sharedInstance.fetchChatTranscript
        )
    }()
}

extension CoreSdkClient.PushNotifications {
    static let live = Self(
        applicationDidRegisterForRemoteNotificationsWithDeviceToken:
            Salemove.sharedInstance.pushNotifications.application(_:didRegisterForRemoteNotificationsWithDeviceToken:)
    )
}

extension CoreSdkClient.AppDelegate {
    static func live() -> Self {
        let salemoveDelegate = SalemoveAppDelegate()
        return .init(
            applicationDidFinishLaunchingWithOptions: salemoveDelegate.application(_:didFinishLaunchingWithOptions:),
            applicationDidBecomeActive: salemoveDelegate.applicationDidBecomeActive
        )
    }
}
