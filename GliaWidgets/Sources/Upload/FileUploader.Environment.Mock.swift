#if DEBUG

extension FileUploader.Environment {
    static let mock = FileUploader.Environment(
        uploadFileToEngagement: { _, _, _ in },
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
