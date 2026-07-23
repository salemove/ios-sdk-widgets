import Foundation
@testable import GliaWidgets
@_spi(GliaWidgets) import GliaCoreSDK

extension ChatCoordinator.Environment {
    static var mock = Self(
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
        uiScreen: .mock,
        createThumbnailGenerator: { .mock },
        createFileDownload: { _, _, _ in .mock() },
        fromHistory: { false },
        fetchSiteConfigurations: { try .mock() },
        getCurrentEngagement: { .mock() },
        getNonTransferredSecureConversationEngagement: { .mock() },
        submitSurveyAnswer: { _, _, _ in },
        uuid: { .mock },
        uiApplication: .mock,
        fetchChatHistory: { [] },
        createFileUploadListModel: { _ in .mock() },
        queueIds: [],
        listQueues: { [.mock()] },
        isAuthenticated: { false },
        interactor: .mock(),
        startSocketObservation: { },
        stopSocketObservation: { },
        createSendMessagePayload: { _, _ in .mock() },
        proximityManager: .mock,
        log: .mock,
        timerProviding: .mock,
        notificationCenter: .mock,
        maximumUploads: { 2 },
        cameraDeviceManager: { .mock },
        flipCameraButtonStyle: .nop,
        alertManager: .mock(),
        queuesMonitor: .mock(),
        createEntryWidget: { _ in .mock() },
        shouldShowLeaveSecureConversationDialog: { _ in false },
        leaveCurrentSecureConversation: .nop,
        switchToEngagement: .nop,
        markUnreadMessagesDelay: { .mock },
        combineScheduler: .mock
    )
}
