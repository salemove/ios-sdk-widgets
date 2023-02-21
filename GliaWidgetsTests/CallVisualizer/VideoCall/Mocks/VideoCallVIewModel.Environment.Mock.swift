
#if DEBUG

extension CallVisualizer.VideoCallViewModel.Environment {
    static let mock = Self(
        data: .mock,
        uuid: { .mock },
        gcd: .mock,
        imageViewCache: .mock,
        timerProviding: .mock,
        uiApplication: .mock,
        date: { .mock },
        engagedOperator: { .mock() },
        screenShareHandler: .mock()
    )
}

#endif
