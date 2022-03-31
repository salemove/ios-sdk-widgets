/// Style of a bubble that represents a call or the entirety of Widgets when they are minimized.
public class BubbleStyle {
    /// Style of a user's image shown in the bubble.
    public var userImage: UserImageStyle

    /// Style of a badge shown on the bubble.
    public var badge: BadgeStyle?

    /// Accessibility related properties.
    public var accessibility: Accessibility

    ///
    /// - Parameters:
    ///   - userImage: Style of a user's image shown in the bubble.
    ///   - badge: Style of a badge shown on the bubble.
    ///   - accessibility: Accessibility related properties.
    public init(
        userImage: UserImageStyle,
        badge: BadgeStyle? = nil,
        accessibility: Accessibility
    ) {
        self.userImage = userImage
        self.badge = badge
        self.accessibility = accessibility
    }
}
