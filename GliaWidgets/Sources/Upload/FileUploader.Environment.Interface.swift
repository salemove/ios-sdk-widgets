import Foundation

extension FileUploader {
    struct Environment {
        var uploadFile: UploadFile
        var fileManager: FoundationBased.FileManager
        var data: FoundationBased.Data
        var date: () -> Date
        var gcd: GCD
        var localFileThumbnailQueue: FoundationBased.OperationQueue
        var uiImage: UIKitBased.UIImage
        var uuid: () -> UUID
    }
}

extension FileUploader.Environment {
    typealias UploadFile = FileUpload.Environment.UploadFile
}
