#if DEBUG

extension CallVisualizer.Environment {
    static let mock = Self(
        timerProviding: .mock,
        requestVisitorCode: { _ in .init() }
    )
}

#endif
