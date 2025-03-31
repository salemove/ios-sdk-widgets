import Foundation

extension ChatCoordinator {
    struct Environment {
        var secureConversations: CoreSdkClient.SecureConversations
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
        var getNonTransferredSecureConversationEngagement: CoreSdkClient.GetCurrentEngagement
        var submitSurveyAnswer: CoreSdkClient.SubmitSurveyAnswer
        var uuid: () -> UUID
        var uiApplication: UIKitBased.UIApplication
        var fetchChatHistory: CoreSdkClient.FetchChatHistory
        var createFileUploadListModel: SecureConversations.FileUploadListViewModel.Create
        var queueIds: [String]
        var listQueues: CoreSdkClient.ListQueues
        var messagesWithUnreadCountLoaderScheduler: CoreSdkClient.ReactiveSwift.DateScheduler
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
        var queuesMonitor: QueuesMonitor
        var createEntryWidget: EntryWidgetBuilder
        var shouldShowLeaveSecureConversationDialog: (SecureConversations.ShouldShowLeaveCurrentConversationSource) -> Bool
        /// The value returning by the command corresponds to decision made by visitor
        /// whether to leave current conversation:
        /// - `true` - visitor decided to leave the conversation;
        /// - `false` - visitor decided to stay;
        var leaveCurrentSecureConversation: Command<Bool>
        var switchToEngagement: Command<EngagementKind>
        var markUnreadMessagesDelay: () -> DispatchQueue.SchedulerTimeType.Stride
        var combineScheduler: AnyCombineScheduler
    }
}

extension ChatCoordinator.Environment {
    static func create(
        with environment: EngagementCoordinator.Environment,
        interactor: Interactor,
        shouldShowLeaveSecureConversationDialog: @escaping (SecureConversations.ShouldShowLeaveCurrentConversationSource) -> Bool,
        leaveCurrentSecureConversation: Command<Bool>,
        switchToEngagement: Command<EngagementKind>
    ) -> Self {
        .init(
            secureConversations: environment.secureConversations,
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
            getNonTransferredSecureConversationEngagement: environment.getNonTransferredSecureConversationEngagement,
            submitSurveyAnswer: environment.submitSurveyAnswer,
            uuid: environment.uuid,
            uiApplication: environment.uiApplication,
            fetchChatHistory: environment.fetchChatHistory,
            createFileUploadListModel: environment.createFileUploadListModel,
            queueIds: interactor.queueIds ?? [],
            listQueues: environment.listQueues,
            messagesWithUnreadCountLoaderScheduler: environment.messagesWithUnreadCountLoaderScheduler,
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
            alertManager: environment.alertManager,
            queuesMonitor: environment.queuesMonitor,
            createEntryWidget: environment.createEntryWidget,
            shouldShowLeaveSecureConversationDialog: shouldShowLeaveSecureConversationDialog,
            leaveCurrentSecureConversation: leaveCurrentSecureConversation,
            switchToEngagement: switchToEngagement,
            markUnreadMessagesDelay: environment.markUnreadMessagesDelay,
            combineScheduler: environment.combineScheduler
        )
    }

    static func create(with environment: SecureConversations.Coordinator.Environment) -> Self {
        .init(
            secureConversations: environment.secureConversations,
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
            getNonTransferredSecureConversationEngagement: environment.getNonTransferredSecureConversationEngagement,
            submitSurveyAnswer: environment.submitSurveyAnswer,
            uuid: environment.uuid,
            uiApplication: environment.uiApplication,
            fetchChatHistory: environment.fetchChatHistory,
            createFileUploadListModel: environment.createFileUploadListModel,
            queueIds: environment.queueIds,
            listQueues: environment.listQueues,
            messagesWithUnreadCountLoaderScheduler: environment.messagesWithUnreadCountLoaderScheduler,
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
            alertManager: environment.alertManager,
            queuesMonitor: environment.queuesMonitor,
            createEntryWidget: environment.createEntryWidget,
            shouldShowLeaveSecureConversationDialog: environment.shouldShowLeaveSecureConversationDialog,
            leaveCurrentSecureConversation: environment.leaveCurrentSecureConversation,
            switchToEngagement: environment.switchToEngagement,
            markUnreadMessagesDelay: environment.markUnreadMessagesDelay,
            combineScheduler: environment.combineScheduler
        )
    }
}
