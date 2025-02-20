import Foundation
@testable import GliaWidgets

extension CallCoordinator.Environment {
    static let mock = Self(
        fetchFile: { engagementFile, progress, completion in },
        downloadSecureFile: { file, progress, completion in .mock },
        uploadFileToEngagement: { file, progress, completion in },
        fileManager: .mock,
        data: .mock,
        date: { .mock },
        gcd: .mock,
        createThumbnailGenerator: { .mock },
        createFileDownload: { file, storage, environment in .mock() },
        fromHistory: { false },
        fetchSiteConfigurations: { completion in },
        getCurrentEngagement: { .mock() },
        getNonTransferredSecureConversationEngagement: { .mock() },
        timerProviding: .mock,
        submitSurveyAnswer: { answers, surveyId, engagementId, completion in },
        uuid: { .mock },
        uiApplication: .mock,
        uiScreen: .mock,
        notificationCenter: .mock,
        fetchChatHistory: { completion in },
        createFileUploadListModel: { environment in .mock() },
        createSendMessagePayload: { content, attachment in .mock() },
        proximityManager: .mock,
        log: .mock,
        snackBar: .mock,
        cameraDeviceManager: { .mock },
        flipCameraButtonStyle: .nop,
        alertManager: .mock(),
        isAuthenticated: { false },
        secureMarkMessagesAsRead: { _ in .mock },
        markUnreadMessagesDelay: { .mock },
        combineScheduler: .mock,
        createEntryWidget: { _ in .mock() }
    )
}
