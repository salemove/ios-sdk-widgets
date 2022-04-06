#if DEBUG
extension ViewFactory {
    static func mock(
        theme: Theme = .mock(),
        environment: Environment = .mock
    ) -> ViewFactory {
        .init(
            with: theme,
            environment: environment
        )
    }
}
#endif
