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

#if DEBUG
extension FileUploader.Environment {
    static func mock(
        uploadFile: UploadFile = .mock,
        fileManager: FoundationBased.FileManager = .mock,
        data: FoundationBased.Data = .mock,
        date: @escaping () -> Date = { .mock },
        gcd: GCD = .mock,
        uiScreen: UIKitBased.UIScreen = .mock,
        createThumbnailGenerator: @escaping () -> QuickLookBased.ThumbnailGenerator = { .mock },
        uuid: @escaping () -> UUID = { .mock }
    ) -> Self {
        .init(
            uploadFile: uploadFile,
            fileManager: fileManager,
            data: data,
            date: date,
            gcd: gcd,
            uiScreen: uiScreen,
            createThumbnailGenerator: createThumbnailGenerator,
            uuid: uuid
        )
    }
}
#endif
