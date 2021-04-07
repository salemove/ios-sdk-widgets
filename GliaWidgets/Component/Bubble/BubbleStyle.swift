/// Style of a (minimized) bubble.
public class BubbleStyle {
    /// Style of a user's image shown in  bubble.
    public var userImage: UserImageStyle

    /// Style of a badge shown on a bubble.
    public var badge: BadgeStyle?

    ///
    /// - Parameters:
    ///   - userImage: Style of a user's image shown in  bubble.
    ///   - badge: Style of a badge shown on a bubble.
    ///
    public init(userImage: UserImageStyle,
                badge: BadgeStyle? = nil) {
        self.userImage = userImage
        self.badge = badge
    }
}
