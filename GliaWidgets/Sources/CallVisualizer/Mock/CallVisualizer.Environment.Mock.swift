#if DEBUG

extension CallVisualizer.Environment {
    static let mock = Self(
        data: .mock,
        uuid: { .mock },
        gcd: .mock,
        imageViewCache: .mock,
        timerProviding: .mock,
        uiApplication: .mock,
        requestVisitorCode: { _ in .init() },
        interactorProviding: { .mock() },
        callVisualizerPresenter: .init(presenter: { nil }),
        bundleManaging: .init { .main },
        screenShareHandler: .mock(),
        audioSession: .mock,
        date: { .mock },
        engagedOperator: { .mock() },
        uiConfig: { nil },
        assetsBuilder: { .standard }
    )
}

#endif
