#if DEBUG
extension Interactor.Environment {
    static let mock = Self(
        coreSdk: .mock,
        queuesMonitor: .mock(),
        gcd: .mock,
        log: .mock
    )
}
#endif
