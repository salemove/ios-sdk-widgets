#if DEBUG

extension CallVisualizer.VideoCallViewModel.Environment {
    static let mock = Self(
        data: .mock,
        uuid: { .mock },
        gcd: .mock,
        imageViewCache: .mock,
        timerProviding: .mock,
        uiApplication: .mock,
        notificationCenter: .mock,
        date: { .mock },
        engagedOperator: { .mock() },
        screenShareHandler: .mock,
        proximityManager: .mock,
        log: .mock
    )
}

#endif
