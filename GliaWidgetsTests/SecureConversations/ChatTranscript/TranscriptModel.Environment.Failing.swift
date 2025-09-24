@testable import GliaWidgets
@_spi(GliaWidgets) import GliaCoreSDK

extension SecureConversations.TranscriptModel.Environment {
    static let failing = SecureConversations.TranscriptModel.Environment(
        secureConversations: .failing,
        fetchFile: { _, _ in
            fail("\(Self.self).fetchFile")
            throw NSError(domain: "fetchFile", code: -1)
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
        fetchChatHistory: {
            fail("\(Self.self).fetchChatHistory")
            throw NSError(domain: "fetchChatHistory", code: -1)
        },
        uiApplication: .failing,
        queueIds: [],
        getQueues: {
            fail("\(Self.self).getQueues")
            throw NSError(domain: "getQueues", code: -1)
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
        fetchSiteConfigurations: {
            fail("\(Self.self).fetchSiteConfigurations")
            throw NSError(domain: "fetchSiteConfigurations", code: -1)
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
