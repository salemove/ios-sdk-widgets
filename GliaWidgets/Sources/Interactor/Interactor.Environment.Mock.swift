#if DEBUG
extension Interactor.Environment {
    static let mock = Self(
        coreSdk: .mock,
        gcd: .mock,
        log: .mock
    )
}
#endif
