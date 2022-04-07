#if DEBUG
extension FileDownload {
    static func mock(
        file: ChatEngagementFile = .mock(),
        storage: DataStorage = FileSystemStorage.mock(),
        environment: Environment = .mock
    ) -> FileDownload {
        .init(
            with: file,
            storage: storage,
            environment: environment
        )
    }
}
#endif
