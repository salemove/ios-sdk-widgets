#if DEBUG

extension FileUploader.Environment {
    static let mock = FileUploader.Environment(
        uploadFile: .mock,
        fileManager: .mock,
        data: .mock,
        date: { .mock },
        gcd: .mock,
        uiScreen: .mock,
        createThumbnailGenerator: { .mock },
        uuid: { .mock }
    )
}

#endif
