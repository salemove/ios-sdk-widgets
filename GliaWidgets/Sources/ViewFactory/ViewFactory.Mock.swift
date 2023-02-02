#if DEBUG
extension ViewFactory {
    static func mock(
        theme: Theme = .mock(),
        messageRenderer: MessageRenderer? = .mock,
        environment: Environment = .mock
    ) -> ViewFactory {
        .init(
            with: theme,
            messageRenderer: messageRenderer,
            environment: environment
        )
    }
}
#endif
