@testable import GliaWidgets
@_spi(GliaWidgets) import GliaCoreSDK

extension ChatViewModel.Environment {
    static func failing(
        fetchChatHistory: CoreSdkClient.FetchChatHistory? = nil
    ) -> Self {
        .init(
            secureConversations: .failing,
            fetchFile: { _, _, _ in
                fail("\(Self.self).fetchFile")
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
            getNonTransferredSecureConversationEngagement: { nil },
            timerProviding: .mock,
            uuid: {
                fail("\(Self.self).uuid")
                return .mock
            },
            uiApplication: .failing,
            fetchChatHistory: fetchChatHistory ?? {
                fail("\(Self.self).fetchChatHistory")
                throw NSError(domain: "CoreSdkClient", code: -1, userInfo: nil)
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
            cameraDeviceManager: { .failing },
            flipCameraButtonStyle: .nop,
            alertManager: .mock(),
            isAuthenticated: {
                fail("\(Self.self).isAuthenticated")
                return false
            },
            notificationCenter: .mock,
            markUnreadMessagesDelay: { .mock },
            combineScheduler: .mock,
            createEntryWidget: { _ in
                fail("\(Self.self).createEntryWidget")
                return .mock()
            },
            topBannerItemsStyle: .mock(),
            switchToEngagement: .init { _ in
                fail("\(Self.self).switchToEngagement")
            },
            shouldShowLeaveSecureConversationDialog: { _ in
                fail("\(Self.self).shouldShowLeaveSecureConversationDialog")
                return false
            }
        )
    }
}
