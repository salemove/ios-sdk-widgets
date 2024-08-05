import Foundation

extension FileDownloader {
    struct Environment {
        var fetchFile: CoreSdkClient.FetchFile
        var downloadSecureFile: CoreSdkClient.DownloadSecureFile
        var fileManager: FoundationBased.FileManager
        var data: FoundationBased.Data
        var date: () -> Date
        var gcd: GCD
        var uiScreen: UIKitBased.UIScreen
        var createThumbnailGenerator: () -> QuickLookBased.ThumbnailGenerator
        var createFileDownload: CreateFileDownload
    }
}

extension FileDownloader.Environment {
    static func create(with environment: SecureConversations.TranscriptModel.Environment) -> Self {
        .init(
            fetchFile: environment.fetchFile,
            downloadSecureFile: environment.downloadSecureFile,
            fileManager: environment.fileManager,
            data: environment.data,
            date: environment.date,
            gcd: environment.gcd,
            uiScreen: environment.uiScreen,
            createThumbnailGenerator: environment.createThumbnailGenerator,
            createFileDownload: environment.createFileDownload
        )
    }

    static func create(with environment: ChatViewModel.Environment) -> Self {
        .init(
            fetchFile: environment.fetchFile,
            downloadSecureFile: environment.downloadSecureFile,
            fileManager: environment.fileManager,
            data: environment.data,
            date: environment.date,
            gcd: environment.gcd,
            uiScreen: environment.uiScreen,
            createThumbnailGenerator: environment.createThumbnailGenerator,
            createFileDownload: environment.createFileDownload
        )
    }
}
