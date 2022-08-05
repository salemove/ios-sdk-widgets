#if DEBUG
extension GliaViewController {
    static func mock(
        bubbleView: BubbleView,
        delegate: GliaViewControllerDelegate?,
        features: Features
    ) -> GliaViewController {
        .init(
            bubbleView: bubbleView,
            delegate: delegate,
            features: features
        )
    }
}
#endif
