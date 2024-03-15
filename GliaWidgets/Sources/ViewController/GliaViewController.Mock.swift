#if DEBUG
extension GliaViewController {
    static func mock(
        bubbleView: BubbleView = .mock(),
        delegate: GliaViewControllerDelegate? = nil,
        features: Features = .all
    ) -> GliaViewController {
        .init(
            bubbleView: bubbleView,
            delegate: delegate,
            features: features,
            environment: .init(
                uiApplication: .mock,
                uiScreen: .mock,
                log: .mock,
                animate: { _, animations, completion in
                    animations()
                    completion(true)
                }
            )
        )
    }
}
#endif
