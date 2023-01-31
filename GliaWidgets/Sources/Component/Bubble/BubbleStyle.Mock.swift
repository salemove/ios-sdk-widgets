#if DEBUG
extension BubbleStyle {
    static func mock(
        userImage: UserImageStyle = .mock(),
        badge: BadgeStyle = .mock(),
        onHoldOverlay: OnHoldOverlayStyle = .mock(),
        accessibility: Accessibility = .unsupported
    ) -> BubbleStyle {
        .init(
            userImage: userImage,
            badge: badge,
            onHoldOverlay: onHoldOverlay,
            accessibility: accessibility
        )
    }
}
#endif
