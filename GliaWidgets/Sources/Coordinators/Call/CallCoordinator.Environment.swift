import Foundation

extension CallCoordinator {
    struct Environment {
        var fetchFile: CoreSdkClient.FetchFile
        var downloadSecureFile: CoreSdkClient.DownloadSecureFile
        var uploadFileToEngagement: CoreSdkClient.UploadFileToEngagement
        var fileManager: FoundationBased.FileManager
        var data: FoundationBased.Data
        var date: () -> Date
        var gcd: GCD
        var createThumbnailGenerator: () -> QuickLookBased.ThumbnailGenerator
        var createFileDownload: FileDownloader.CreateFileDownload
        var fromHistory: () -> Bool
        var fetchSiteConfigurations: CoreSdkClient.FetchSiteConfigurations
        var getCurrentEngagement: CoreSdkClient.GetCurrentEngagement
        var getNonTransferredSecureConversationEngagement: CoreSdkClient.GetCurrentEngagement
        var timerProviding: FoundationBased.Timer.Providing
        var submitSurveyAnswer: CoreSdkClient.SubmitSurveyAnswer
        var uuid: () -> UUID
        var uiApplication: UIKitBased.UIApplication
        var uiScreen: UIKitBased.UIScreen
        var notificationCenter: FoundationBased.NotificationCenter
        var fetchChatHistory: CoreSdkClient.FetchChatHistory
        var createFileUploadListModel: SecureConversations.FileUploadListViewModel.Create
        var createSendMessagePayload: CoreSdkClient.CreateSendMessagePayload
        var proximityManager: ProximityManager
        var log: CoreSdkClient.Logger
        var snackBar: SnackBar
        var cameraDeviceManager: CoreSdkClient.GetCameraDeviceManageable
        var flipCameraButtonStyle: FlipCameraButtonStyle
        var alertManager: AlertManager
        var isAuthenticated: () -> Bool
        var secureMarkMessagesAsRead: CoreSdkClient.SecureMarkMessagesAsRead
        var markUnreadMessagesDelay: () -> DispatchQueue.SchedulerTimeType.Stride
        var combineScheduler: AnyCombineScheduler
        var createEntryWidget: EntryWidgetBuilder
    }
}

extension CallCoordinator.Environment {
    static func create(with environment: EngagementCoordinator.Environment) -> Self {
        .init(
            fetchFile: environment.fetchFile,
            downloadSecureFile: environment.downloadSecureFile,
            uploadFileToEngagement: environment.uploadFileToEngagement,
            fileManager: environment.fileManager,
            data: environment.data,
            date: environment.date,
            gcd: environment.gcd,
            createThumbnailGenerator: environment.createThumbnailGenerator,
            createFileDownload: environment.createFileDownload,
            fromHistory: environment.loadChatMessagesFromHistory,
            fetchSiteConfigurations: environment.fetchSiteConfigurations,
            getCurrentEngagement: environment.getCurrentEngagement,
            getNonTransferredSecureConversationEngagement: environment.getNonTransferredSecureConversationEngagement,
            timerProviding: environment.timerProviding,
            submitSurveyAnswer: environment.submitSurveyAnswer,
            uuid: environment.uuid,
            uiApplication: environment.uiApplication,
            uiScreen: environment.uiScreen,
            notificationCenter: environment.notificationCenter,
            fetchChatHistory: environment.fetchChatHistory,
            createFileUploadListModel: environment.createFileUploadListModel,
            createSendMessagePayload: environment.createSendMessagePayload,
            proximityManager: environment.proximityManager,
            log: environment.log,
            snackBar: environment.snackBar,
            cameraDeviceManager: environment.cameraDeviceManager,
            flipCameraButtonStyle: environment.flipCameraButtonStyle,
            alertManager: environment.alertManager,
            isAuthenticated: environment.isAuthenticated,
            secureMarkMessagesAsRead: environment.secureMarkMessagesAsRead,
            markUnreadMessagesDelay: environment.markUnreadMessagesDelay,
            combineScheduler: environment.combineScheduler,
            createEntryWidget: environment.createEntryWidget
        )
    }
}
