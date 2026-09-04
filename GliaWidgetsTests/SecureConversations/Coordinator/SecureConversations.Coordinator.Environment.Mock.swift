import Foundation
@testable import GliaWidgets
@_spi(GliaWidgets) import GliaCoreSDK

extension SecureConversations.Coordinator.Environment {
    static let mock = Self(
        secureConversations: .mock,
        queueIds: [],
        listQueues: { [.mock()] },
        createFileUploader: { _, _ in .mock() },
        fileManager: .mock,
        data: .mock,
        date: { .mock },
        gcd: .mock,
        createThumbnailGenerator: { .mock },
        uuid: { .mock },
        uiApplication: .mock,
        uiScreen: .mock,
        notificationCenter: .mock,
        createFileUploadListModel: { _ in .mock() },
        viewFactory: .mock(),
        fetchFile: { _, _ in .mock() },
        createFileDownload: { _, _, _ in .mock() },
        loadChatMessagesFromHistory: { true },
        fetchChatHistory: { [] },
        fetchSiteConfigurations: { try .mock() },
        chatCall: .init(with: .mock()),
        unreadMessages: .init(with: 0),
        showsCallBubble: true,
        isWindowVisible: .init(with: true),
        uploadFileToEngagement: { _, _ in
            try await Task.sleep(nanoseconds: UInt64.max)
            throw CancellationError()
        },
        getCurrentEngagement: { .mock() },
        getNonTransferredSecureConversationEngagement: { .mock() },
        submitSurveyAnswer: { _, _, _ in },
        interactor: .mock(),
        isAuthenticated: { true },
        startSocketObservation: { },
        stopSocketObservation: { },
        createSendMessagePayload: { _, _ in .mock() },
        orientationManager: .mock(),
        proximityManager: .mock,
        log: .mock,
        timerProviding: .mock,
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
