@testable import GliaWidgets
@_spi(GliaWidgets) import GliaCoreSDK

extension EngagementCoordinator.Environment {
    static let failing = Self(
        secureConversations: .failing,
        fetchFile: { _, _ in
            fail("\(Self.self).fetchFile")
            throw NSError(domain: "fetchFile", code: -1)
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
        fetchSiteConfigurations: {
            fail("\(Self.self).fetchSiteConfigurations")
            throw NSError(domain: "fetchSiteConfigurations", code: -1)
        },
        getCurrentEngagement: {
            fail("\(Self.self).getCurrentEngagement")
            return nil
        },
        getNonTransferredSecureConversationEngagement: {
            fail("\(Self.self).getNonTransferredSecureConversationEngagement")
            return nil
        },
        submitSurveyAnswer: { _, _, _ in
            fail("\(Self.self).submitSurveyAnswer")
            throw NSError(domain: "submitSurveyAnswer", code: -1)
        },
        uiApplication: .failing,
        uiScreen: .failing,
        notificationCenter: .failing,
        fetchChatHistory: {
            fail("\(Self.self).fetchChatHistory")
            throw NSError(domain: "fetchChatHistory", code: -1)
        },
        listQueues: {
            fail("\(Self.self).getQueues")
            throw NSError(domain: "getQueues", code: -1)
        },
        createFileUploader: { _, _ in
            .failing
        },
        createFileUploadListModel: { _ in
            fail("\(Self.self).createFileUploadListModel")
            return .mock()
        },
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
