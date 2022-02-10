#if DEBUG
extension FileUpload {
    static func mock(
        localFile: LocalFile = .mock(),
        storage: DataStorage = FileSystemStorage.mock(),
        environment: Environment = .mock
    ) -> FileUpload {
        .init(
            with: localFile,
            storage: storage,
            environment: environment
        )
    }
}
#endif
