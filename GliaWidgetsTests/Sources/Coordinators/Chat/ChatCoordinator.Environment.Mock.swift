import Foundation
@testable import GliaWidgets

extension ChatCoordinator.Environment {
    static var mock = Self(
        fetchFile: { engagementFile, progress, completion in },
        uploadFileToEngagement: { file, progress, completion in },
        fileManager: .mock,
        data: .mock,
        date: { .mock },
        gcd: .mock,
        uiScreen: .mock,
        createThumbnailGenerator: { .mock },
        createFileDownload: { file, storage, environment in .mock() },
        fromHistory: { false },
        fetchSiteConfigurations: { completion in },
        getCurrentEngagement: { .mock() },
        submitSurveyAnswer: { answers, surveyId, engagementId, completion in },
        uuid: { .mock },
        uiApplication: .mock,
        fetchChatHistory: { completion in },
        createFileUploadListModel: { environment in .mock() },
        sendSecureMessagePayload: { secureMessagePayload, queueIds, completion in .mock },
        queueIds: [],
        listQueues: { completion in },
        secureUploadFile: { file, progress, completion in .mock },
        getSecureUnreadMessageCount: { callback in },
        messagesWithUnreadCountLoaderScheduler: CoreSdkClient.reactiveSwiftDateSchedulerMock,
        secureMarkMessagesAsRead: { callback in .mock },
        downloadSecureFile: { file, progress, completion in .mock },
        isAuthenticated: { false },
        interactor: .mock(),
        startSocketObservation: { },
        stopSocketObservation: { },
        createSendMessagePayload: { content, attachment in .mock() },
        proximityManager: .mock,
        log: .mock,
        timerProviding: .mock,
        snackBar: .mock,
        notificationCenter: .mock,
        operatorRequestHandlerService: .mock()
    )
}
