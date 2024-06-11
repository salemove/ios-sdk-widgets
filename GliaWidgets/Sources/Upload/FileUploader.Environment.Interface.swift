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

extension FileUploader.Environment {
    static func create(with environment: SecureConversations.Coordinator.Environment) -> Self {
        .init(
            uploadFile: .toSecureMessaging(environment.uploadSecureFile),
            fileManager: environment.fileManager,
            data: environment.data,
            date: environment.date,
            gcd: environment.gcd,
            uiScreen: environment.uiScreen,
            createThumbnailGenerator: environment.createThumbnailGenerator,
            uuid: environment.uuid
        )
    }

    static func create(with environment: SecureConversations.TranscriptModel.Environment) -> Self {
        .init(
            uploadFile: .toSecureMessaging(environment.secureUploadFile),
            fileManager: environment.fileManager,
            data: environment.data,
            date: environment.date,
            gcd: environment.gcd,
            uiScreen: environment.uiScreen,
            createThumbnailGenerator: environment.createThumbnailGenerator,
            uuid: environment.uuid
        )
    }
}
