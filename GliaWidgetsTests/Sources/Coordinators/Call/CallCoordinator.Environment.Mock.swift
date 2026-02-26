import Foundation
@testable import GliaWidgets
@_spi(GliaWidgets) import GliaCoreSDK

extension CallCoordinator.Environment {
    static let mock = Self(
        secureConversations: .mock,
        fetchFile: { engagementFile, progress in .mock() },
        uploadFileToEngagement: { file, progress, completion in },
        fileManager: .mock,
        data: .mock,
        date: { .mock },
        gcd: .mock,
        createThumbnailGenerator: { .mock },
        createFileDownload: { file, storage, environment in .mock() },
        fromHistory: { false },
        fetchSiteConfigurations: { try .mock() },
        getCurrentEngagement: { .mock() },
        getNonTransferredSecureConversationEngagement: { .mock() },
        timerProviding: .mock,
        submitSurveyAnswer: { answers, surveyId, engagementId in },
        uuid: { .mock },
        uiApplication: .mock,
        uiScreen: .mock,
        notificationCenter: .mock,
        fetchChatHistory: { [] },
        createFileUploadListModel: { environment in .mock() },
        createSendMessagePayload: { content, attachment in .mock() },
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
