#if DEBUG
@_spi(GliaWidgets) import GliaCoreSDK

extension CallVisualizer.Environment {
    static let mock = Self(
        data: .mock,
        uuid: { .mock },
        gcd: .mock,
        imageViewCache: .mock,
        timerProviding: .mock,
        uiApplication: .mock,
        uiScreen: .mock,
        uiDevice: .mock,
        notificationCenter: .mock,
        requestVisitorCode: { _ in .init() },
        interactorPublisher: .mock(.mock()),
        callVisualizerPresenter: .init(presenter: { nil }),
        bundleManaging: .init { .main },
        audioSession: .mock,
        date: { .mock },
        engagedOperator: { .mock() },
        theme: .init(),
        assetsBuilder: { .standard },
        getCurrentEngagement: CoreSdkClient.mock.getCurrentEngagement,
        orientationManager: .mock(),
        proximityManager: .mock,
        log: .mock,
        fetchSiteConfigurations: { _ in },
        coreSdk: .mock,
        cameraDeviceManager: { .mock },
        alertManager: .mock(),
        combineScheduler: .mock
    )
}

#endif
