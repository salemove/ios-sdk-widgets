#if DEBUG
@_spi(GliaWidgets) import GliaCoreSDK

extension EngagementCoordinator.Environment {
    static let mock = Self(
        secureConversations: .mock,
        fetchFile: { _, _, _ in },
        uploadFileToEngagement: { _, _, _ in },
        audioSession: .mock,
        uuid: { .mock },
        fileManager: .mock,
        data: .mock,
        date: { .mock },
        gcd: .mock,
        createThumbnailGenerator: { .mock },
        createFileDownload: { _, _, _ in .mock() },
        loadChatMessagesFromHistory: { false },
        timerProviding: .mock,
        fetchSiteConfigurations: { _ in },
        getCurrentEngagement: { nil },
        getNonTransferredSecureConversationEngagement: { return nil },
        submitSurveyAnswer: { _, _, _, _ in },
        uiApplication: .mock,
        uiScreen: .mock,
        notificationCenter: .mock,
        fetchChatHistory: { _ in },
        listQueues: { [.mock()] },
        createFileUploader: FileUploader.mock,
        createFileUploadListModel: SecureConversations.FileUploadListViewModel.mock(environment:),
        messagesWithUnreadCountLoaderScheduler: CoreSdkClient.reactiveSwiftDateSchedulerMock,
        markUnreadMessagesDelay: { .mock },
        isAuthenticated: { false },
        startSocketObservation: {},
        stopSocketObservation: {},
        pushNotifications: .mock,
        createSendMessagePayload: { _, _ in .mock() },
        orientationManager: .mock(),
        proximityManager: .mock,
        log: .mock,
        snackBar: .mock,
        maximumUploads: { 2 },
        cameraDeviceManager: {
            .mock
        },
        flipCameraButtonStyle: .nop,
        alertManager: .mock(),
        queuesMonitor: .mock(),
        hasPendingInteraction: { false },
        createEntryWidget: { _ in .mock() },
        dismissManager: .init { _, _, _ in },
        combineScheduler: .mock
    )
}
#endif
