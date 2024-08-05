import Foundation

extension ChatCoordinator {
    struct Environment {
        var fetchFile: CoreSdkClient.FetchFile
        var uploadFileToEngagement: CoreSdkClient.UploadFileToEngagement
        var fileManager: FoundationBased.FileManager
        var data: FoundationBased.Data
        var date: () -> Date
        var gcd: GCD
        var uiScreen: UIKitBased.UIScreen
        var createThumbnailGenerator: () -> QuickLookBased.ThumbnailGenerator
        var createFileDownload: FileDownloader.CreateFileDownload
        var fromHistory: () -> Bool
        var fetchSiteConfigurations: CoreSdkClient.FetchSiteConfigurations
        var getCurrentEngagement: CoreSdkClient.GetCurrentEngagement
        var submitSurveyAnswer: CoreSdkClient.SubmitSurveyAnswer
        var uuid: () -> UUID
        var uiApplication: UIKitBased.UIApplication
        var fetchChatHistory: CoreSdkClient.FetchChatHistory
        var createFileUploadListModel: SecureConversations.FileUploadListViewModel.Create
        var sendSecureMessagePayload: CoreSdkClient.SendSecureMessagePayload
        var queueIds: [String]
        var listQueues: CoreSdkClient.ListQueues
        var secureUploadFile: CoreSdkClient.SecureConversationsUploadFile
        var getSecureUnreadMessageCount: CoreSdkClient.GetSecureUnreadMessageCount
        var messagesWithUnreadCountLoaderScheduler: CoreSdkClient.ReactiveSwift.DateScheduler
        var secureMarkMessagesAsRead: CoreSdkClient.SecureMarkMessagesAsRead
        var downloadSecureFile: CoreSdkClient.DownloadSecureFile
        var isAuthenticated: () -> Bool
        var interactor: Interactor
        var startSocketObservation: CoreSdkClient.StartSocketObservation
        var stopSocketObservation: CoreSdkClient.StopSocketObservation
        var createSendMessagePayload: CoreSdkClient.CreateSendMessagePayload
        var proximityManager: ProximityManager
        var log: CoreSdkClient.Logger
        var timerProviding: FoundationBased.Timer.Providing
        var snackBar: SnackBar
        var notificationCenter: FoundationBased.NotificationCenter
        var maximumUploads: () -> Int
        var cameraDeviceManager: CoreSdkClient.GetCameraDeviceManageable
        var flipCameraButtonStyle: FlipCameraButtonStyle
        var alertManager: AlertManager
    }
}

extension ChatCoordinator.Environment {
    static func create(
        with environment: EngagementCoordinator.Environment,
        interactor: Interactor
    ) -> Self {
        .init(
            fetchFile: environment.fetchFile,
            uploadFileToEngagement: environment.uploadFileToEngagement,
            fileManager: environment.fileManager,
            data: environment.data,
            date: environment.date,
            gcd: environment.gcd,
            uiScreen: environment.uiScreen,
            createThumbnailGenerator: environment.createThumbnailGenerator,
            createFileDownload: environment.createFileDownload,
            fromHistory: environment.loadChatMessagesFromHistory,
            fetchSiteConfigurations: environment.fetchSiteConfigurations,
            getCurrentEngagement: environment.getCurrentEngagement,
            submitSurveyAnswer: environment.submitSurveyAnswer,
            uuid: environment.uuid,
            uiApplication: environment.uiApplication,
            fetchChatHistory: environment.fetchChatHistory,
            createFileUploadListModel: environment.createFileUploadListModel,
            sendSecureMessagePayload: environment.sendSecureMessagePayload,
            queueIds: interactor.queueIds,
            listQueues: environment.listQueues,
            secureUploadFile: environment.uploadSecureFile,
            getSecureUnreadMessageCount: environment.getSecureUnreadMessageCount,
            messagesWithUnreadCountLoaderScheduler: environment.messagesWithUnreadCountLoaderScheduler,
            secureMarkMessagesAsRead: environment.secureMarkMessagesAsRead,
            downloadSecureFile: environment.downloadSecureFile,
            isAuthenticated: environment.isAuthenticated,
            interactor: interactor,
            startSocketObservation: environment.startSocketObservation,
            stopSocketObservation: environment.stopSocketObservation,
            createSendMessagePayload: environment.createSendMessagePayload,
            proximityManager: environment.proximityManager,
            log: environment.log,
            timerProviding: environment.timerProviding,
            snackBar: environment.snackBar,
            notificationCenter: environment.notificationCenter,
            maximumUploads: environment.maximumUploads,
            cameraDeviceManager: environment.cameraDeviceManager,
            flipCameraButtonStyle: environment.flipCameraButtonStyle,
            alertManager: environment.alertManager
        )
    }

    static func create(with environment: SecureConversations.Coordinator.Environment) -> Self {
        .init(
            fetchFile: environment.fetchFile,
            uploadFileToEngagement: environment.uploadFileToEngagement,
            fileManager: environment.fileManager,
            data: environment.data,
            date: environment.date,
            gcd: environment.gcd,
            uiScreen: environment.uiScreen,
            createThumbnailGenerator: environment.createThumbnailGenerator,
            createFileDownload: environment.createFileDownload,
            fromHistory: environment.loadChatMessagesFromHistory,
            fetchSiteConfigurations: environment.fetchSiteConfigurations,
            getCurrentEngagement: environment.getCurrentEngagement,
            submitSurveyAnswer: environment.submitSurveyAnswer,
            uuid: environment.uuid,
            uiApplication: environment.uiApplication,
            fetchChatHistory: environment.fetchChatHistory,
            createFileUploadListModel: environment.createFileUploadListModel,
            sendSecureMessagePayload: environment.sendSecureMessagePayload,
            queueIds: environment.queueIds,
            listQueues: environment.listQueues,
            secureUploadFile: environment.uploadSecureFile,
            getSecureUnreadMessageCount: environment.getSecureUnreadMessageCount,
            messagesWithUnreadCountLoaderScheduler: environment.messagesWithUnreadCountLoaderScheduler,
            secureMarkMessagesAsRead: environment.secureMarkMessagesAsRead,
            downloadSecureFile: environment.downloadSecureFile,
            isAuthenticated: environment.isAuthenticated,
            interactor: environment.interactor,
            startSocketObservation: environment.startSocketObservation,
            stopSocketObservation: environment.stopSocketObservation,
            createSendMessagePayload: environment.createSendMessagePayload,
            proximityManager: environment.proximityManager,
            log: environment.log,
            timerProviding: environment.timerProviding,
            snackBar: environment.snackBar,
            notificationCenter: environment.notificationCenter,
            maximumUploads: environment.maximumUploads,
            cameraDeviceManager: environment.cameraDeviceManager,
            flipCameraButtonStyle: environment.flipCameraButtonStyle,
            alertManager: environment.alertManager
        )
    }
}
