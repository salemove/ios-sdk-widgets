import Foundation
@testable import GliaWidgets
@_spi(GliaWidgets) import GliaCoreSDK

extension SecureConversations.Coordinator.Environment {
    static let mock = Self(
        secureConversations: .mock,
        queueIds: [],
        listQueues: { completion in },
        createFileUploader: { maximumUploads, environment in .mock() },
        fileManager: .mock,
        data: .mock,
        date: { .mock },
        gcd: .mock,
        createThumbnailGenerator: { .mock },
        uuid: { .mock },
        uiApplication: .mock,
        uiScreen: .mock,
        notificationCenter: .mock,
        createFileUploadListModel: { environment in .mock() },
        viewFactory: .mock(),
        fetchFile: { engagementFile, progress, completion in },
        createFileDownload: { file, storage, environment in .mock() },
        loadChatMessagesFromHistory: { true },
        fetchChatHistory: { completion in },
        fetchSiteConfigurations: { completion in },
        chatCall: .init(with: .mock()),
        unreadMessages: .init(with: 0),
        showsCallBubble: true,
        isWindowVisible: .init(with: true),
        uploadFileToEngagement: { file, progress, completion in },
        getCurrentEngagement: { .mock() },
        getNonTransferredSecureConversationEngagement: { .mock() },
        submitSurveyAnswer: { answers, surveyId, engagementId, completion in },
        interactor: .mock(),
        messagesWithUnreadCountLoaderScheduler: CoreSdkClient.reactiveSwiftDateSchedulerMock,
        isAuthenticated: { true },
        startSocketObservation: { },
        stopSocketObservation: { },
        createSendMessagePayload: { content, attachment in .mock() },
        orientationManager: .mock(),
        proximityManager: .mock,
        log: .mock,
        timerProviding: .mock,
        snackBar: SnackBar(
            present: { text, style, viewController, bottomOffset, timerProviding, gcd, notificationCenter in
            }
        ),
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
