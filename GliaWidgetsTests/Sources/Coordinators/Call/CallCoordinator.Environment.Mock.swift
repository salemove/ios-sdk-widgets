import Foundation
@testable import GliaWidgets
@_spi(GliaWidgets) import GliaCoreSDK

extension CallCoordinator.Environment {
    static let mock = Self(
        secureConversations: .mock,
        fetchFile: { _, _ in .mock() },
        uploadFileToEngagement: { _, _ in
            try await Task.sleep(nanoseconds: UInt64.max)
            throw CancellationError()
        },
        fileManager: .mock,
        data: .mock,
        date: { .mock },
        gcd: .mock,
        createThumbnailGenerator: { .mock },
        createFileDownload: { _, _, _ in .mock() },
        fromHistory: { false },
        fetchSiteConfigurations: { try .mock() },
        getCurrentEngagement: { .mock() },
        getNonTransferredSecureConversationEngagement: { .mock() },
        timerProviding: .mock,
        submitSurveyAnswer: { _, _, _ in },
        uuid: { .mock },
        uiApplication: .mock,
        uiScreen: .mock,
        notificationCenter: .mock,
        fetchChatHistory: { [] },
        createFileUploadListModel: { _ in .mock() },
        createSendMessagePayload: { _, _ in .mock() },
        proximityManager: .mock,
        log: .mock,
        cameraDeviceManager: { .mock },
        flipCameraButtonStyle: .nop,
        alertManager: .mock(),
        isAuthenticated: { false },
        markUnreadMessagesDelay: { .mock },
        combineScheduler: .mock,
        createEntryWidget: { _ in .mock() }
    )
}
