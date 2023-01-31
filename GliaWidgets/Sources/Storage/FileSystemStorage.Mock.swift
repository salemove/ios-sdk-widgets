#if DEBUG
extension FileSystemStorage {
    static func mock(
        directory: Directory = .documents(.mock),
        expiration: Expiration = .none,
        environment: Environment = .mock
    ) -> FileSystemStorage {
        .init(
            directory: directory,
            expiration: expiration,
            environment: environment
        )
    }
}
#endif
