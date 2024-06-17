extension LocalFile {
    struct Environment {
        var fileManager: FoundationBased.FileManager
        var gcd: GCD
        var uiScreen: UIKitBased.UIScreen
        var thumbnailGenerator: QuickLookBased.ThumbnailGenerator
    }
}

extension LocalFile.Environment {
    static func create(with environment: FileUploader.Environment) -> Self {
        .init(
            fileManager: environment.fileManager,
            gcd: environment.gcd,
            uiScreen: environment.uiScreen,
            thumbnailGenerator: environment.createThumbnailGenerator()
        )
    }

    static func create(with environment: FileDownload.Environment) -> Self {
        .init(
            fileManager: environment.fileManager,
            gcd: environment.gcd,
            uiScreen: environment.uiScreen,
            thumbnailGenerator: environment.createThumbnailGenerator()
        )
    }
}

#if DEBUG
extension LocalFile.Environment {
    static func mock(
        fileManager: FoundationBased.FileManager = .mock,
        gcd: GCD = .mock,
        uiScreen: UIKitBased.UIScreen = .mock,
        thumbnailGenerator: QuickLookBased.ThumbnailGenerator = .mock
    ) -> Self {
        .init(
            fileManager: fileManager,
            gcd: gcd,
            uiScreen: uiScreen,
            thumbnailGenerator: thumbnailGenerator
        )
    }
}
#endif
