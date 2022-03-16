#if DEBUG
extension Call {
    static func mock(
        kind: CallKind = .audio,
        environment: Environment = .mock
    ) -> Call {
        .init(
            kind,
            environment: environment
        )
    }
}
#endif
