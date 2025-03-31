@testable import GliaWidgets

extension SecureConversations.TranscriptModel.Environment {
    static let failing = SecureConversations.TranscriptModel.Environment(
        secureConversations: .failing,
        fetchFile: { _, _, _ in
            fail("\(Self.self).fetchFile")
        },
        fileManager: .failing,
        data: .failing,
        date: {
            fail("\(Self.self).date")
            return .mock
        },
        gcd: .failing,
        uiScreen: .failing,
        createThumbnailGenerator: { .failing },
        createFileDownload: { _, _, _ in
            return .failing
        },
        loadChatMessagesFromHistory: {
            fail("\(Self.self).loadChatMessagesFromHistory")
            return false
        },
        fetchChatHistory: { _ in
            fail("\(Self.self).fetchChatHistory")
        },
        uiApplication: .failing,
        queueIds: [],
        getQueues: { _ in
            fail("\(Self.self).listQueues")
        },
        createFileUploadListModel: { _ in
            fail("\(Self.self).createFileUploadListModel")
            return .mock()
        },
        uuid: {
            fail("\(Self.self).uuid")
            return .mock
        },
        fileUploadListStyle: .mock,
        fetchSiteConfigurations: { _ in
            fail("\(Self.self).fetchSiteConfigurations")
        },
        messagesWithUnreadCountLoaderScheduler: CoreSdkClient.ReactiveSwift.TestScheduler(startDate: .mock),
        interactor: .mock(),
        startSocketObservation: {
            fail("\(Self.self).startSocketObservation")
        },
        stopSocketObservation: {
            fail("\(Self.self).stopSocketObservation")
        },
        createSendMessagePayload: { _, _ in
            fail("\(Self.self).createSendMessagePayload")
            return .mock()
        },
        log: .failing,
        maximumUploads: {
            fail("\(Self.self).maximumUploads")
            return 2
        },
        shouldShowLeaveSecureConversationDialog: { _ in
            fail("\(Self.self).shouldShowLeaveSecureConversationDialog")
            return false
        },
        leaveCurrentSecureConversation: .init { _ in
            fail("\(Self.self).leaveCurrentSecureConversation")
        },
        createEntryWidget: { _ in
            fail("\(Self.self).createEntryWidget")
            return .mock()
        },
        switchToEngagement: .init { _ in
            fail("\(Self.self).switchToEngagement")
        },
        topBannerItemsStyle: .mock(),
        notificationCenter: .failing,
        markUnreadMessagesDelay: {
            fail("\(Self.self).markUnreadMessagesDelay")
            return .mock
        },
        combineScheduler: .mock
    )
}
