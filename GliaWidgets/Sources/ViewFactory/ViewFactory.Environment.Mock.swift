#if DEBUG
@_spi(GliaWidgets) import GliaCoreSDK

extension ViewFactory.Environment {
    static let mock = Self(
        data: .mock,
        uuid: { .mock },
        gcd: .mock,
        imageViewCache: .mock,
        timerProviding: .mock,
        uiApplication: .mock,
        uiScreen: .mock,
        log: .mock,
        uiDevice: .mock,
        combineScheduler: .mock
    )
}
#endif
