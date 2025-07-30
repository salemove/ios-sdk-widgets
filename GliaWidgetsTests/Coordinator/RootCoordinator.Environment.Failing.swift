@testable import GliaWidgets
@_spi(GliaWidgets) import GliaCoreSDK

extension EngagementCoordinator.Environment {
    static let failing = Self(
        secureConversations: .failing,
        fetchFile: { _, _, _ in
            fail("\(Self.self).fetchFile")
        },
        uploadFileToEngagement: { _, _, _ in
            fail("\(Self.self).uploadFileToEngagement")
        },
        audioSession: .failing,
        uuid: {
            fail("\(Self.self).uuid")
            return .mock
        },
        fileManager: .failing,
        data: .failing,
        date: {
            fail("\(Self.self).date")
            return .mock
        },
        gcd: .failing,
        createThumbnailGenerator: { .failing },
        createFileDownload: { _, _, _ in .failing },
        loadChatMessagesFromHistory: {
            fail("\(Self.self).loadChatMessagesFromHistory")
            return true
        },
        timerProviding: .failing,
        fetchSiteConfigurations: { _ in
            fail("\(Self.self).fetchSiteConfigurations")
        },
        getCurrentEngagement: {
            fail("\(Self.self).getCurrentEngagement")
            return nil
        },
        getNonTransferredSecureConversationEngagement: {
            fail("\(Self.self).getNonTransferredSecureConversationEngagement")
            return nil
        },
        submitSurveyAnswer: { _, _, _, _ in
            fail("\(Self.self).submitSurveyAnswer")
        },
        uiApplication: .failing,
        uiScreen: .failing,
        notificationCenter: .failing,
        fetchChatHistory: {
            fail("\(Self.self).fetchChatHistory")
            throw NSError(domain: "fetchChatHistory", code: -1, userInfo: nil)
        },
        listQueues: { _ in fail("\(Self.self).listQueues") },
        createFileUploader: { _, _ in
            .failing
        },
        createFileUploadListModel: { _ in
            fail("\(Self.self).createFileUploadListModel")
            return .mock()
        },
        messagesWithUnreadCountLoaderScheduler: CoreSdkClient.reactiveSwiftDateSchedulerMock,
        markUnreadMessagesDelay: {
            fail("\(Self.self).markUnreadMessagesDelay")
            return .mock
        },
        isAuthenticated: {
            fail("\(Self.self).isAuthenticated")
            return false
        },
        startSocketObservation: {
            fail("\(Self.self).startSocketObservation")
        },
        stopSocketObservation: {
            fail("\(Self.self).stopSocketObservation")
        },
        pushNotifications: .failing,
        createSendMessagePayload: { _, _ in
            fail("\(Self.self).createSendMessagePayload")
            return .mock()
        },
        orientationManager: .mock(),
        proximityManager: .failing,
        log: .failing,
        snackBar: .failing,
        maximumUploads: {
            fail("\(Self.self).maximumUploads")
            return 2
        },
        cameraDeviceManager: { .failing },
        flipCameraButtonStyle: .nop,
        alertManager: .failing(viewFactory: .mock()),
        queuesMonitor: .failing,
        hasPendingInteraction: {
            fail("\(Self.self).hasPendingInteraction")
            return false
        },
        createEntryWidget: { _ in
            fail("\(Self.self).createEntryWidget")
            return .mock()
        },
        dismissManager: .failing,
        combineScheduler: .mock
    )
}
