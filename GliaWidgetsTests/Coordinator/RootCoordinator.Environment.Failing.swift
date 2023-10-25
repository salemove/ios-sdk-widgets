@testable import GliaWidgets

extension EngagementCoordinator.Environment {
    static let failing = Self(
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
        submitSurveyAnswer: { _, _, _, _ in
            fail("\(Self.self).submitSurveyAnswer")
        },
        uiApplication: .failing,
        uiScreen: .failing,
        notificationCenter: .failing,
        fetchChatHistory: { _ in fail("\(Self.self).fetchChatHistory") },
        listQueues: { _ in fail("\(Self.self).listQueues") },
        sendSecureMessagePayload: { _, _, _ in
            fail("\(Self.self).sendSecureMessagePayload")
            return .mock
        },
        createFileUploader: { _, _ in
            .failing
        },
        createFileUploadListModel: { _ in
            fail("\(Self.self).createFileUploadListModel")
            return .mock()

        },
        uploadSecureFile: { _, _, _ in
            fail("\(Self.self).uploadSecureFile")
            return .mock
        },
        getSecureUnreadMessageCount: { _ in
            fail("\(Self.self).getSecureUnreadMessageCount")
        },
        messagesWithUnreadCountLoaderScheduler: CoreSdkClient.reactiveSwiftDateSchedulerMock,
        secureMarkMessagesAsRead: { _ in
            fail("\(Self.self).secureMarkMessagesAsRead")
            return .mock
        },
        downloadSecureFile: { _, _, _ in
            fail("\(Self.self).downloadSecureFile")
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
        proximityManager: .failing
    )
}
