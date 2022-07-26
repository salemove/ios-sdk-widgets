#if DEBUG
extension BubbleView {
    static func mock(
        with bubbleStyle: BubbleStyle,
        environment: Environment
    ) -> BubbleView {
        .init(
            with: bubbleStyle,
            environment: environment
        )
    }
}
#endif
