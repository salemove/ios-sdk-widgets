#if DEBUG
extension LocalFile {
    static func mock(
        url: URL = .mock,
        environment: Environment = .mock
    ) -> LocalFile {
        .init(
            with: url,
            environment: environment
        )
    }
}
#endif
