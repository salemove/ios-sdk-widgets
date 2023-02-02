#if DEBUG
extension FileSystemStorage.Environment {
    static let mock = Self(
        fileManager: .mock,
        data: .mock,
        date: { .mock }
    )
}
#endif
