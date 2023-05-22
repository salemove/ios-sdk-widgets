import Foundation

extension FileUploader {
    struct Environment {
        var uploadFile: UploadFile
        var fileManager: FoundationBased.FileManager
        var data: FoundationBased.Data
        var date: () -> Date
        var gcd: GCD
        var uiScreen: UIKitBased.UIScreen
        var createThumbnailGenerator: () -> QuickLookBased.ThumbnailGenerator
        var uuid: () -> UUID
    }
}

extension FileUploader.Environment {
    typealias UploadFile = FileUpload.Environment.UploadFile
}
