#if DEBUG
extension LocalFile.Environment {
    static let mock = Self(
        fileManager: .mock,
        gcd: .mock,
        uiScreen: .mock,
        thumbnailGenerator: .mock
    )
}
#endif
