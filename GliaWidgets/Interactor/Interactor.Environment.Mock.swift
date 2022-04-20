#if DEBUG
extension Interactor.Environment {
    static let mock = Self(
        coreSdk: .mock,
        gcd: .mock
    )
}
#endif
