#if DEBUG
extension EngagementCoordinator.Environment {
    static let mock = Self(
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
        submitSurveyAnswer: { _, _, _, _ in },
        uiApplication: .mock,
        uiScreen: .mock,
        notificationCenter: .mock,
        fetchChatHistory: { _ in },
        listQueues: { _ in },
        sendSecureMessagePayload: { _, _, _ in .mock },
        createFileUploader: FileUploader.mock,
        createFileUploadListModel: SecureConversations.FileUploadListViewModel.mock(environment:),
        uploadSecureFile: { _, _, _ in .mock },
        getSecureUnreadMessageCount: { _ in },
        messagesWithUnreadCountLoaderScheduler: CoreSdkClient.reactiveSwiftDateSchedulerMock,
        secureMarkMessagesAsRead: { _ in .mock },
        downloadSecureFile: { _, _, _ in .mock },
        isAuthenticated: { false },
        startSocketObservation: {},
        stopSocketObservation: {},
        pushNotifications: .mock,
        createSendMessagePayload: { _, _ in .mock() },
        orientationManager: .mock(),
        proximityManager: .mock,
        log: .mock,
        snackBar: .mock,
        operatorRequestHandlerService: .mock(),
        maximumUploads: { 2 },
        cameraDeviceManager: {
            .mock
        },
        flipCameraButtonStyle: .nop
    )
}
#endif
