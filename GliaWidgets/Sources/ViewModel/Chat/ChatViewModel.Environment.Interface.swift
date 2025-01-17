import Foundation

extension EngagementViewModel {
    struct Environment {
        var fetchFile: CoreSdkClient.FetchFile
        var downloadSecureFile: CoreSdkClient.DownloadSecureFile
        var uploadFileToEngagement: CoreSdkClient.UploadFileToEngagement
        var fileManager: FoundationBased.FileManager
        var data: FoundationBased.Data
        var date: () -> Date
        var gcd: GCD
        var uiScreen: UIKitBased.UIScreen
        var createThumbnailGenerator: () -> QuickLookBased.ThumbnailGenerator
        var createFileDownload: FileDownloader.CreateFileDownload
        var loadChatMessagesFromHistory: () -> Bool
        var fetchSiteConfigurations: CoreSdkClient.FetchSiteConfigurations
        var getCurrentEngagement: CoreSdkClient.GetCurrentEngagement
        var getNonTransferredSecureConversationEngagement: CoreSdkClient.GetCurrentEngagement
        var timerProviding: FoundationBased.Timer.Providing
        var uuid: () -> UUID
        var uiApplication: UIKitBased.UIApplication
        var fetchChatHistory: CoreSdkClient.FetchChatHistory
        var fileUploadListStyle: FileUploadListStyle
        var createFileUploadListModel: SecureConversations.FileUploadListViewModel.Create
        var createSendMessagePayload: CoreSdkClient.CreateSendMessagePayload
        var proximityManager: ProximityManager
        var log: CoreSdkClient.Logger
        var cameraDeviceManager: CoreSdkClient.GetCameraDeviceManageable
        var flipCameraButtonStyle: FlipCameraButtonStyle
        var alertManager: AlertManager
        var isAuthenticated: () -> Bool
        var notificationCenter: FoundationBased.NotificationCenter
        var secureMarkMessagesAsRead: CoreSdkClient.SecureMarkMessagesAsRead
        var markUnreadMessagesDelay: () -> DispatchQueue.SchedulerTimeType.Stride
        var combineScheduler: CombineBased.CombineScheduler
    }
}

extension EngagementViewModel.Environment {
    static func create(
        with environment: ChatCoordinator.Environment,
        viewFactory: ViewFactory
    ) -> EngagementViewModel.Environment {
        .init(
            fetchFile: environment.fetchFile,
            downloadSecureFile: environment.downloadSecureFile,
            uploadFileToEngagement: environment.uploadFileToEngagement,
            fileManager: environment.fileManager,
            data: environment.data,
            date: environment.date,
            gcd: environment.gcd,
            uiScreen: environment.uiScreen,
            createThumbnailGenerator: environment.createThumbnailGenerator,
            createFileDownload: environment.createFileDownload,
            loadChatMessagesFromHistory: environment.fromHistory,
            fetchSiteConfigurations: environment.fetchSiteConfigurations,
            getCurrentEngagement: environment.getCurrentEngagement,
            getNonTransferredSecureConversationEngagement: environment.getNonTransferredSecureConversationEngagement,
            timerProviding: environment.timerProviding,
            uuid: environment.uuid,
            uiApplication: environment.uiApplication,
            fetchChatHistory: environment.fetchChatHistory,
            fileUploadListStyle: viewFactory.theme.chatStyle.messageEntry.enabled.uploadList,
            createFileUploadListModel: environment.createFileUploadListModel,
            createSendMessagePayload: environment.createSendMessagePayload,
            proximityManager: environment.proximityManager,
            log: environment.log,
            cameraDeviceManager: environment.cameraDeviceManager,
            flipCameraButtonStyle: environment.flipCameraButtonStyle,
            alertManager: environment.alertManager,
            isAuthenticated: environment.isAuthenticated,
            notificationCenter: environment.notificationCenter,
            secureMarkMessagesAsRead: environment.secureMarkMessagesAsRead,
            markUnreadMessagesDelay: environment.markUnreadMessagesDelay,
            combineScheduler: environment.combineScheduler
        )
    }

    static func create(
        with environment: CallCoordinator.Environment,
        viewFactory: ViewFactory
    ) -> EngagementViewModel.Environment {
        .init(
            fetchFile: environment.fetchFile,
            downloadSecureFile: environment.downloadSecureFile,
            uploadFileToEngagement: environment.uploadFileToEngagement,
            fileManager: environment.fileManager,
            data: environment.data,
            date: environment.date,
            gcd: environment.gcd,
            uiScreen: environment.uiScreen,
            createThumbnailGenerator: environment.createThumbnailGenerator,
            createFileDownload: environment.createFileDownload,
            loadChatMessagesFromHistory: environment.fromHistory,
            fetchSiteConfigurations: environment.fetchSiteConfigurations,
            getCurrentEngagement: environment.getCurrentEngagement,
            getNonTransferredSecureConversationEngagement: environment.getNonTransferredSecureConversationEngagement,
            timerProviding: environment.timerProviding,
            uuid: environment.uuid,
            uiApplication: environment.uiApplication,
            fetchChatHistory: environment.fetchChatHistory,
            fileUploadListStyle: viewFactory.theme.chatStyle.messageEntry.enabled.uploadList,
            createFileUploadListModel: environment.createFileUploadListModel,
            createSendMessagePayload: environment.createSendMessagePayload,
            proximityManager: environment.proximityManager,
            log: environment.log,
            cameraDeviceManager: environment.cameraDeviceManager,
            flipCameraButtonStyle: environment.flipCameraButtonStyle,
            alertManager: environment.alertManager,
            isAuthenticated: environment.isAuthenticated,
            notificationCenter: environment.notificationCenter,
            secureMarkMessagesAsRead: environment.secureMarkMessagesAsRead,
            markUnreadMessagesDelay: environment.markUnreadMessagesDelay,
            combineScheduler: environment.combineScheduler
        )
    }
}
