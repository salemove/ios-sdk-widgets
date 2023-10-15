#if DEBUG
extension CoreSDKConfigurator {
    static let mock = CoreSDKConfigurator(
        configureWithInteractor: { _ in },
        configureWithConfiguration: { _, _ in }
    )
}
#endif
