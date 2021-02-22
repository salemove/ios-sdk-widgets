public class BubbleStyle {
    public var userImage: UserImageStyle
    public var badge: BadgeStyle?

    public init(userImage: UserImageStyle,
                badge: BadgeStyle? = nil) {
        self.userImage = userImage
        self.badge = badge
    }
}
