#if DEBUG

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
        interactorProviding: { .mock() },
        callVisualizerPresenter: .init(presenter: { nil }),
        bundleManaging: .init { .main },
        screenShareHandler: .mock,
        audioSession: .mock,
        date: { .mock },
        engagedOperator: { .mock() },
        theme: .init(),
        assetsBuilder: { .standard },
        getCurrentEngagement: CoreSdkClient.mock.getCurrentEngagement,
        orientationManager: .mock(),
        proximityManager: .mock
    )
}

#endif
