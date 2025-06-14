import Foundation

extension EngagementCoordinator {
    struct Environment {
        var secureConversations: CoreSdkClient.SecureConversations
        var fetchFile: CoreSdkClient.FetchFile
        var uploadFileToEngagement: CoreSdkClient.UploadFileToEngagement
        var audioSession: Glia.Environment.AudioSession
        var uuid: () -> UUID
        var fileManager: FoundationBased.FileManager
        var data: FoundationBased.Data
        var date: () -> Date
        var gcd: GCD
        var createThumbnailGenerator: () -> QuickLookBased.ThumbnailGenerator
        var createFileDownload: FileDownloader.CreateFileDownload
        var loadChatMessagesFromHistory: () -> Bool
        var timerProviding: FoundationBased.Timer.Providing
        var fetchSiteConfigurations: CoreSdkClient.FetchSiteConfigurations
        var getCurrentEngagement: CoreSdkClient.GetCurrentEngagement
        var getNonTransferredSecureConversationEngagement: CoreSdkClient.GetCurrentEngagement
        var submitSurveyAnswer: CoreSdkClient.SubmitSurveyAnswer
        var uiApplication: UIKitBased.UIApplication
        var uiScreen: UIKitBased.UIScreen
        var notificationCenter: FoundationBased.NotificationCenter
        var fetchChatHistory: CoreSdkClient.FetchChatHistory
        var listQueues: CoreSdkClient.GetQueues
        var createFileUploader: FileUploader.Create
        var createFileUploadListModel: SecureConversations.FileUploadListViewModel.Create
        var messagesWithUnreadCountLoaderScheduler: CoreSdkClient.ReactiveSwift.DateScheduler
        var markUnreadMessagesDelay: () -> DispatchQueue.SchedulerTimeType.Stride
        var isAuthenticated: () -> Bool
        var startSocketObservation: CoreSdkClient.StartSocketObservation
        var stopSocketObservation: CoreSdkClient.StopSocketObservation
        var pushNotifications: CoreSdkClient.PushNotifications
        var createSendMessagePayload: CoreSdkClient.CreateSendMessagePayload
        var orientationManager: OrientationManager
        var proximityManager: ProximityManager
        var log: CoreSdkClient.Logger
        var snackBar: SnackBar
        var maximumUploads: () -> Int
        var cameraDeviceManager: CoreSdkClient.GetCameraDeviceManageable
        var flipCameraButtonStyle: FlipCameraButtonStyle
        var alertManager: AlertManager
        var queuesMonitor: QueuesMonitor
        var hasPendingInteraction: () -> Bool
        var createEntryWidget: EntryWidgetBuilder
        var dismissManager: GliaPresenter.DismissManager
        var combineScheduler: CoreSdkClient.AnyCombineScheduler
    }
}

extension EngagementCoordinator.Environment {
    static func create(
        with environment: Glia.Environment,
        loggerPhase: Glia.LoggerPhase,
        markUnreadMessagesDelay: @escaping () -> DispatchQueue.SchedulerTimeType.Stride,
        maximumUploads: @escaping () -> Int,
        viewFactory: ViewFactory,
        alertManager: AlertManager,
        queuesMonitor: QueuesMonitor,
        createEntryWidget: @escaping EntryWidgetBuilder,
        hasPendingInteraction: @escaping () -> Bool
    ) -> Self {
        .init(
            secureConversations: environment.coreSdk.secureConversations,
            fetchFile: environment.coreSdk.fetchFile,
            uploadFileToEngagement: environment.coreSdk.uploadFileToEngagement,
            audioSession: environment.audioSession,
            uuid: environment.uuid,
            fileManager: environment.fileManager,
            data: environment.data,
            date: environment.date,
            gcd: environment.gcd,
            createThumbnailGenerator: environment.createThumbnailGenerator,
            createFileDownload: environment.createFileDownload,
            loadChatMessagesFromHistory: environment.loadChatMessagesFromHistory,
            timerProviding: environment.timerProviding,
            fetchSiteConfigurations: environment.coreSdk.fetchSiteConfigurations,
            getCurrentEngagement: environment.coreSdk.getCurrentEngagement,
            getNonTransferredSecureConversationEngagement: environment.coreSdk.getNonTransferredSecureConversationEngagement,
            submitSurveyAnswer: environment.coreSdk.submitSurveyAnswer,
            uiApplication: environment.uiApplication,
            uiScreen: environment.uiScreen,
            notificationCenter: environment.notificationCenter,
            fetchChatHistory: environment.coreSdk.fetchChatHistory,
            listQueues: environment.coreSdk.getQueues,
            createFileUploader: environment.createFileUploader,
            createFileUploadListModel: environment.createFileUploadListModel,
            messagesWithUnreadCountLoaderScheduler: environment.messagesWithUnreadCountLoaderScheduler,
            markUnreadMessagesDelay: markUnreadMessagesDelay,
            isAuthenticated: environment.isAuthenticated,
            startSocketObservation: environment.coreSdk.startSocketObservation,
            stopSocketObservation: environment.coreSdk.stopSocketObservation,
            pushNotifications: environment.coreSdk.pushNotifications,
            createSendMessagePayload: environment.coreSdk.createSendMessagePayload,
            orientationManager: environment.orientationManager,
            proximityManager: environment.proximityManager,
            log: loggerPhase.logger,
            snackBar: environment.snackBar,
            maximumUploads: maximumUploads,
            cameraDeviceManager: environment.cameraDeviceManager,
            flipCameraButtonStyle: viewFactory.theme.call.flipCameraButtonStyle,
            alertManager: alertManager,
            queuesMonitor: queuesMonitor,
            hasPendingInteraction: hasPendingInteraction,
            createEntryWidget: createEntryWidget,
            dismissManager: environment.dismissManager,
            combineScheduler: environment.combineScheduler
        )
    }
}
