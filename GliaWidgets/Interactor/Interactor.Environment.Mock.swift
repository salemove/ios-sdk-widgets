#if DEBUG
extension Interactor.Environment {
    static let mock = Self.init(coreSdk: .mock)
}
#endif
