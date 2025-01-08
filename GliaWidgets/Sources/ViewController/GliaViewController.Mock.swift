#if DEBUG
extension GliaViewController {
    static func mock(
        bubbleView: BubbleView = .mock(),
        delegate: ((GliaViewControllerEvent) -> Void)? = nil,
        sceneProvider: SceneProvider? = .none,
        features: Features = .all
    ) -> GliaViewController {
        .init(
            bubbleView: bubbleView,
            delegate: delegate,
            sceneProvider: sceneProvider,
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
