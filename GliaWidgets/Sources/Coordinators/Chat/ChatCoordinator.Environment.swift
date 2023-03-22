import Foundation

extension ChatCoordinator {
    struct Environment {
        var fetchFile: CoreSdkClient.FetchFile
        var sendSelectedOptionValue: CoreSdkClient.SendSelectedOptionValue
        var uploadFileToEngagement: CoreSdkClient.UploadFileToEngagement
        var fileManager: FoundationBased.FileManager
        var data: FoundationBased.Data
        var date: () -> Date
        var gcd: GCD
        var localFileThumbnailQueue: FoundationBased.OperationQueue
        var uiImage: UIKitBased.UIImage
        var createFileDownload: FileDownloader.CreateFileDownload
        var fromHistory: () -> Bool
        var fetchSiteConfigurations: CoreSdkClient.FetchSiteConfigurations
        var getCurrentEngagement: CoreSdkClient.GetCurrentEngagement
        var submitSurveyAnswer: CoreSdkClient.SubmitSurveyAnswer
        var uuid: () -> UUID
        var uiApplication: UIKitBased.UIApplication
        var fetchChatHistory: CoreSdkClient.FetchChatHistory
        var createFileUploadListModel: SecureConversations.FileUploadListViewModel.Create
        var sendSecureMessage: CoreSdkClient.SendSecureMessage
        var queueIds: [String]
        var listQueues: CoreSdkClient.ListQueues
        var secureUploadFile: CoreSdkClient.SecureConversationsUploadFile
        var getSecureUnreadMessageCount: CoreSdkClient.GetSecureUnreadMessageCount
        var messagesWithUnreadCountLoaderScheduler: CoreSdkClient.ReactiveSwift.DateScheduler
        var secureMarkMessagesAsRead: CoreSdkClient.SecureMarkMessagesAsRead
        var downloadSecureFile: CoreSdkClient.DownloadSecureFile
    }
}
