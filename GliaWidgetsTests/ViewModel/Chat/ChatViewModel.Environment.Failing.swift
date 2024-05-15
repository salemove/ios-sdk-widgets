@testable import GliaWidgets

extension ChatViewModel.Environment {
    static func failing(
        fetchChatHistory: CoreSdkClient.FetchChatHistory? = nil
    ) -> Self {
        .init(
            fetchFile: { _, _, _ in
                fail("\(Self.self).fetchFile")
            },
            downloadSecureFile: { _, _, _ in
                fail("\(Self.self).downloadSecureFile")
                return .mock
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
            uiScreen: .failing,
            createThumbnailGenerator: { .failing },
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
            },
            createSendMessagePayload: { _, _ in
                fail("\(Self.self).createSendMessagePayload")
                return .mock()
            },
            proximityManager: .failing,
            log: .failing,
            operatorRequestHandlerService: .failing,
            cameraDeviceManager: { .failing },
            flipCameraButtonStyle: .nop
        )
    }
}
