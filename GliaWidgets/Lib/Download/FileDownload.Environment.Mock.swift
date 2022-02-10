#if DEBUG
extension FileDownload.Environment {
    static let mock = Self(
        fetchFile: { _, _, _ in },
        fileManager: .mock,
        gcd: .mock,
        localFileThumbnailQueue: .mock(),
        uiImage: .mock
    )
}
#endif
