#if DEBUG
extension LocalFile.Environment {
    static let mock = Self(
        fileManager: .mock,
        gcd: .mock,
        localFileThumbnailQueue: .mock(),
        uiImage: .mock
    )
}
#endif
