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

    static func mock(
        data: FoundationBased.Data = .mock,
        uuid: @autoclosure @escaping () -> UUID = .mock,
        gcd: GCD = .live,
        imageViewCache: ImageView.Cache = .mock,
        timerProviding: FoundationBased.Timer.Providing = .mock,
        uiApplication: UIKitBased.UIApplication = .mock,
        uiScreen: UIKitBased.UIScreen = .mock,
        log: CoreSdkClient.Logger = .mock,
        uiDevice: UIKitBased.UIDevice = .mock,
        combineScheduler: CoreSdkClient.AnyCombineScheduler = .mock
    ) -> Self {
        .init(
            data: data,
            uuid: uuid,
            gcd: gcd,
            imageViewCache: imageViewCache,
            timerProviding: timerProviding,
            uiApplication: uiApplication,
            uiScreen: uiScreen,
            log: log,
            uiDevice: uiDevice,
            combineScheduler: combineScheduler
        )
    }
}
#endif
