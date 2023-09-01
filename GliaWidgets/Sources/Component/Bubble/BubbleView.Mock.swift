#if DEBUG
extension BubbleView {
    static func mock(
        with bubbleStyle: BubbleStyle = .mock(),
        environment: Environment = .mock()
    ) -> BubbleView {
        .init(
            with: bubbleStyle,
            environment: environment
        )
    }
}

extension BubbleView.Environment {
    static func mock(
        data: FoundationBased.Data = .mock,
        uuid: @escaping () -> UUID = { .mock },
        gcd: GCD = .mock,
        imageViewCache: ImageView.Cache = .mock
    ) -> BubbleView.Environment {
        .init(
            data: data,
            uuid: uuid,
            gcd: gcd,
            imageViewCache: imageViewCache
        )
    }
}
#endif
