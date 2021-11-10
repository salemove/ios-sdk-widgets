import UIKit

// TODO: docs
public struct UnreadMessageIndicatorStyle {
    public var badge: BadgeStyle
    public var userImage: UserImageStyle

    public init(
        badgeFont: UIFont,
        badgeTextColor: UIColor,
        badgeColor: UIColor,
        placeholderImage: UIImage,
        placeholderColor: UIColor,
        placeholderBackgroundColor: UIColor,
        imageBackgroundColor: UIColor
    ) {
        self.badge = BadgeStyle(
            font: badgeFont,
            fontColor: badgeTextColor,
            backgroundColor: badgeColor
        )
        self.userImage = UserImageStyle(
            placeholderImage: placeholderImage,
            placeholderColor: placeholderColor,
            placeholderBackgroundColor: placeholderBackgroundColor,
            imageBackgroundColor: imageBackgroundColor
        )
    }
}
