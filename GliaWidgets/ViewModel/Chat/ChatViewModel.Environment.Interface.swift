import Foundation

extension ChatViewModel {
    struct Environment {
        var chatStorage: Glia.Environment.ChatStorage
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
    }
}
