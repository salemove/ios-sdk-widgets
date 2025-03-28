#if DEBUG

import Foundation

extension ChatViewModel.Environment {
    static let mock = Self(
        fetchFile: { _, _, _ in },
        downloadSecureFile: { _, _, _ in .mock },
        uploadFileToEngagement: { _, _, _ in },
        fileManager: .mock,
        data: .mock,
        date: { .mock },
        gcd: .mock,
        uiScreen: .mock,
        createThumbnailGenerator: { .mock },
        createFileDownload: { file, fileStorage, env in
                .mock(
                    file: file,
                    storage: fileStorage,
                    environment: env
                )
        },
        loadChatMessagesFromHistory: { true },
        fetchSiteConfigurations: { _ in },
        getCurrentEngagement: { return nil },
        getNonTransferredSecureConversationEngagement: { return nil },
        timerProviding: .mock,
        uuid: { UUID.mock },
        uiApplication: .mock,
        fetchChatHistory: { _ in },
        fileUploadListStyle: .initial,
        createFileUploadListModel: SecureConversations.FileUploadListViewModel.mock(environment:),
        createSendMessagePayload: { _, _ in .mock() },
        proximityManager: .mock,
        log: .mock,
        cameraDeviceManager: { .mock },
        flipCameraButtonStyle: .nop,
        alertManager: .mock(),
        isAuthenticated: { false },
        notificationCenter: .mock,
        secureMarkMessagesAsRead: { _ in .mock },
        markUnreadMessagesDelay: { .mock },
        combineScheduler: .mock,
        createEntryWidget: { _ in .mock() },
        topBannerItemsStyle: .mock(),
        switchToEngagement: .nop,
        shouldShowLeaveSecureConversationDialog: { _ in false }
    )
}
#endif
