@testable import GliaWidgets

extension SecureConversations.TranscriptModel.Environment {
    static let failing = SecureConversations.TranscriptModel.Environment(
        fetchFile: { _, _, _ in
            fail("\(Self.self).fetchFile")
        },
        downloadSecureFile: { _, _, _ in
            fail("\(Self.self).downloadSecureFile")
            return .mock
        },
        fileManager: .failing,
        data: .failing,
        date: {
            fail("\(Self.self).date")
            return .mock
        },
        gcd: .failing,
        localFileThumbnailQueue: .failing,
        uiImage: .failing,
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
        sendSecureMessage: { _, _, _, _ in
            fail("\(Self.self).sendSecureMessage")
            return .mock
        },
        queueIds: [],
        listQueues: { completion in
            fail("\(Self.self).listQueues")
        },
        alertConfiguration: .mock(),
        createFileUploadListModel: { _ in
            fail("\(Self.self).createFileUploadListModel")
            return .mock()
        },
        uuid: {
            fail("\(Self.self).uuid")
            return .mock
        },
        secureUploadFile: { _, _, _ in
            fail("\(Self.self).secureUploadFile")
            return .mock
        },
        fileUploadListStyle: .mock,
        fetchSiteConfigurations: { _ in
            fail("\(Self.self).fetchSiteConfigurations")
        },
        getSecureUnreadMessageCount: { _ in
            fail("\(Self.self).getSecureUnreadMessageCount")
        },
        messagesWithUnreadCountLoaderScheduler: CoreSdkClient.ReactiveSwift.TestScheduler(startDate: .mock),
        secureMarkMessagesAsRead: { _ in
            fail("\(Self.self).secureMarkMessagesAsRead")
            return .mock
        },
        interactor: .mock()
    )
}
