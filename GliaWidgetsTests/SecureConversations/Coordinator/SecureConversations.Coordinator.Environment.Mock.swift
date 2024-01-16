import Foundation
@testable import GliaWidgets

extension SecureConversations.Coordinator.Environment {
    static let mock = Self(
        queueIds: [],
        listQueues: { completion in },
        sendSecureMessagePayload: { secureMessagePayload, queueIds, completion in .mock },
        createFileUploader: { maximumUploads, environment in .mock() },
        uploadSecureFile: { file, progress, completion in .mock },
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
        screenShareHandler: .mock,
        isWindowVisible: .init(with: true),
        uploadFileToEngagement: { file, progress, completion in },
        getCurrentEngagement: { .mock() },
        submitSurveyAnswer: { answers, surveyId, engagementId, completion in },
        interactor: .mock(),
        getSecureUnreadMessageCount: { callback in },
        messagesWithUnreadCountLoaderScheduler: CoreSdkClient.reactiveSwiftDateSchedulerMock,
        secureMarkMessagesAsRead: { callback in .mock },
        downloadSecureFile: { file, progress, completion in .mock },
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
        )
    )
}
