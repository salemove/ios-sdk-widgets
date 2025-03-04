import Foundation

extension SecureConversations.Coordinator {
    struct Environment {
        var queueIds: [String]
        var listQueues: CoreSdkClient.ListQueues
        var sendSecureMessagePayload: CoreSdkClient.SendSecureMessagePayload
        var createFileUploader: FileUploader.Create
        var uploadSecureFile: CoreSdkClient.SecureConversationsUploadFile
        var fileManager: FoundationBased.FileManager
        var data: FoundationBased.Data
        var date: () -> Date
        var gcd: GCD
        var createThumbnailGenerator: () -> QuickLookBased.ThumbnailGenerator
        var uuid: () -> UUID
        var uiApplication: UIKitBased.UIApplication
        var uiScreen: UIKitBased.UIScreen
        var notificationCenter: FoundationBased.NotificationCenter
        var createFileUploadListModel: SecureConversations.FileUploadListViewModel.Create
        var viewFactory: ViewFactory
        var fetchFile: CoreSdkClient.FetchFile
        var createFileDownload: FileDownloader.CreateFileDownload
        var loadChatMessagesFromHistory: () -> Bool
        var fetchChatHistory: CoreSdkClient.FetchChatHistory
        var fetchSiteConfigurations: CoreSdkClient.FetchSiteConfigurations
        var chatCall: ObservableValue<Call?>
        var unreadMessages: ObservableValue<Int>
        var showsCallBubble: Bool
        var screenShareHandler: ScreenShareHandler
        var isWindowVisible: ObservableValue<Bool>
        var uploadFileToEngagement: CoreSdkClient.UploadFileToEngagement
        var getCurrentEngagement: CoreSdkClient.GetCurrentEngagement
        var getNonTransferredSecureConversationEngagement: CoreSdkClient.GetCurrentEngagement
        var submitSurveyAnswer: CoreSdkClient.SubmitSurveyAnswer
        var interactor: Interactor
        var getSecureUnreadMessageCount: CoreSdkClient.GetSecureUnreadMessageCount
        var messagesWithUnreadCountLoaderScheduler: CoreSdkClient.ReactiveSwift.DateScheduler
        var secureMarkMessagesAsRead: CoreSdkClient.SecureMarkMessagesAsRead
        var downloadSecureFile: CoreSdkClient.DownloadSecureFile
        var isAuthenticated: () -> Bool
        var startSocketObservation: CoreSdkClient.StartSocketObservation
        var stopSocketObservation: CoreSdkClient.StopSocketObservation
        var createSendMessagePayload: CoreSdkClient.CreateSendMessagePayload
        var orientationManager: OrientationManager
        var proximityManager: ProximityManager
        var log: CoreSdkClient.Logger
        var timerProviding: FoundationBased.Timer.Providing
        var snackBar: SnackBar
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

extension SecureConversations.Coordinator.Environment {
    static func create(
        with environment: EngagementCoordinator.Environment,
        queueIds: [String],
        viewFactory: ViewFactory,
        chatCall: ObservableValue<Call?>,
        unreadMessages: ObservableValue<Int>,
        showCallBubble: Bool,
        screenShareHandler: ScreenShareHandler,
        isWindowVisible: ObservableValue<Bool>,
        interactor: Interactor,
        shouldShowLeaveSecureConversationDialog: @escaping (SecureConversations.ShouldShowLeaveCurrentConversationSource) -> Bool,
        leaveCurrentSecureConversation: Command<Bool>,
        switchToEngagement: Command<EngagementKind>
    ) -> Self {
        .init(
            queueIds: queueIds,
            listQueues: environment.listQueues,
            sendSecureMessagePayload: environment.sendSecureMessagePayload,
            createFileUploader: environment.createFileUploader,
            uploadSecureFile: environment.uploadSecureFile,
            fileManager: environment.fileManager,
            data: environment.data,
            date: environment.date,
            gcd: environment.gcd,
            createThumbnailGenerator: environment.createThumbnailGenerator,
            uuid: environment.uuid,
            uiApplication: environment.uiApplication,
            uiScreen: environment.uiScreen,
            notificationCenter: environment.notificationCenter,
            createFileUploadListModel: environment.createFileUploadListModel,
            viewFactory: viewFactory,
            fetchFile: environment.fetchFile,
            createFileDownload: environment.createFileDownload,
            loadChatMessagesFromHistory: environment.loadChatMessagesFromHistory,
            fetchChatHistory: environment.fetchChatHistory,
            fetchSiteConfigurations: environment.fetchSiteConfigurations,
            chatCall: chatCall,
            unreadMessages: unreadMessages,
            showsCallBubble: showCallBubble,
            screenShareHandler: screenShareHandler,
            isWindowVisible: isWindowVisible,
            uploadFileToEngagement: environment.uploadFileToEngagement,
            getCurrentEngagement: environment.getCurrentEngagement,
            getNonTransferredSecureConversationEngagement: environment.getNonTransferredSecureConversationEngagement,
            submitSurveyAnswer: environment.submitSurveyAnswer,
            interactor: interactor,
            getSecureUnreadMessageCount: environment.getSecureUnreadMessageCount,
            messagesWithUnreadCountLoaderScheduler: environment.messagesWithUnreadCountLoaderScheduler,
            secureMarkMessagesAsRead: environment.secureMarkMessagesAsRead,
            downloadSecureFile: environment.downloadSecureFile,
            isAuthenticated: environment.isAuthenticated,
            startSocketObservation: environment.startSocketObservation,
            stopSocketObservation: environment.stopSocketObservation,
            createSendMessagePayload: environment.createSendMessagePayload,
            orientationManager: environment.orientationManager,
            proximityManager: environment.proximityManager,
            log: environment.log,
            timerProviding: environment.timerProviding,
            snackBar: environment.snackBar,
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
}
