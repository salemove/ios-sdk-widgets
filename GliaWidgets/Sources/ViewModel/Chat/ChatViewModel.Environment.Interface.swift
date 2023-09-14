import Foundation

extension EngagementViewModel {
    struct Environment {
        var fetchFile: CoreSdkClient.FetchFile
        var downloadSecureFile: CoreSdkClient.DownloadSecureFile
        var sendSelectedOptionValue: CoreSdkClient.SendSelectedOptionValue
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
        var timerProviding: FoundationBased.Timer.Providing
        var uuid: () -> UUID
        var uiApplication: UIKitBased.UIApplication
        var fetchChatHistory: CoreSdkClient.FetchChatHistory
        var fileUploadListStyle: FileUploadListStyle
        var createFileUploadListModel: SecureConversations.FileUploadListViewModel.Create
        var createSendMessagePayload: CoreSdkClient.CreateSendMessagePayload
    }
}
