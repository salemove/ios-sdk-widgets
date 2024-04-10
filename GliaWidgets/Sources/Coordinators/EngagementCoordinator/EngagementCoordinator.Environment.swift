import Foundation

extension EngagementCoordinator {
    struct Environment {
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
        var submitSurveyAnswer: CoreSdkClient.SubmitSurveyAnswer
        var uiApplication: UIKitBased.UIApplication
        var uiScreen: UIKitBased.UIScreen
        var notificationCenter: FoundationBased.NotificationCenter
        var fetchChatHistory: CoreSdkClient.FetchChatHistory
        var listQueues: CoreSdkClient.ListQueues
        var sendSecureMessagePayload: CoreSdkClient.SendSecureMessagePayload
        var createFileUploader: FileUploader.Create
        var createFileUploadListModel: SecureConversations.FileUploadListViewModel.Create
        var uploadSecureFile: CoreSdkClient.SecureConversationsUploadFile
        var getSecureUnreadMessageCount: CoreSdkClient.GetSecureUnreadMessageCount
        var messagesWithUnreadCountLoaderScheduler: CoreSdkClient.ReactiveSwift.DateScheduler
        var secureMarkMessagesAsRead: CoreSdkClient.SecureMarkMessagesAsRead
        var downloadSecureFile: CoreSdkClient.DownloadSecureFile
        var isAuthenticated: () -> Bool
        var startSocketObservation: CoreSdkClient.StartSocketObservation
        var stopSocketObservation: CoreSdkClient.StopSocketObservation
        var pushNotifications: CoreSdkClient.PushNotifications
        var createSendMessagePayload: CoreSdkClient.CreateSendMessagePayload
        var orientationManager: OrientationManager
        var proximityManager: ProximityManager
        var log: CoreSdkClient.Logger
        var snackBar: SnackBar
        var operatorRequestHandlerService: OperatorRequestHandlerService
        var maximumUploads: () -> Int
    }
}
