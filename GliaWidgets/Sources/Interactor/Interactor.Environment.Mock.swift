#if DEBUG
extension Interactor.Environment {
    static let mock = Self(
        coreSdk: .mock,
        queuesMonitor: .mock(),
        gcd: .mock,
        log: .mock
    )

    static func mock(gcd: GCD = .mock) -> Self {
        .init(
            coreSdk: .mock,
            queuesMonitor: .mock(),
            gcd: gcd,
            log: .mock
        )
    }
}
#endif
