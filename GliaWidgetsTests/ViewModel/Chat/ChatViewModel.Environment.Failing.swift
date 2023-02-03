@testable import GliaWidgets

extension ChatViewModel.Environment {
    static func failing(
        fetchChatHistory: CoreSdkClient.FetchChatHistory? = nil
    ) -> Self {
        .init(
            fetchFile: { _, _, _ in
                fail("\(Self.self).fetchFile")
            },
            sendSelectedOptionValue: { _, _ in
                fail("\(Self.self).sendSelectedOptionValue")
            },
            uploadFileToEngagement: { _, _, _ in
                fail("\(Self.self).uploadFileToEngagement")
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
                fail("\(Self.self).createFileDownload")
                return .failing
            },
            loadChatMessagesFromHistory: {
                fail("\(Self.self).loadChatMessagesFromHistory")
                return true
            },
            fetchSiteConfigurations: { _ in
                fail("\(Self.self).fetchSiteConfigurations")
            },
            getCurrentEngagement: { nil },
            timerProviding: .mock,
            uuid: {
                fail("\(Self.self).uuid")
                return .mock
            },
            uiApplication: .failing,
            fetchChatHistory: fetchChatHistory ?? { _ in
                fail("\(Self.self).fetchChatHistory")
            },
            fileUploadListStyle: .mock,
            createFileUploadListModel: { _ in
                fail("\(Self.self).createFileUploadListModel")
                return .mock()
            }
        )
    }
}
