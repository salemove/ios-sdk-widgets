#if DEBUG

extension FileUploader.Environment {
    static let mock = FileUploader.Environment(
        uploadFile: .mock,
        fileManager: .mock,
        data: .mock,
        date: { .mock },
        gcd: .mock,
        localFileThumbnailQueue: .mock(),
        uiImage: .mock,
        uuid: { .mock }
    )
}

#endif
