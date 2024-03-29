#if DEBUG
extension FileDownload.Environment {
    static let mock = Self(
        fetchFile: { _, _, _ in },
        downloadSecureFile: { _, _, _ in .mock },
        fileManager: .mock,
        gcd: .mock,
        uiScreen: .mock,
        createThumbnailGenerator: { .mock }
    )
}
#endif
