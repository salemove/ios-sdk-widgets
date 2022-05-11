import UIKit

/// Style of the unread message indicator. It appears in the chat view when a new message is received and the user has scrolled up and is not seeing the end of the chat.
/// It consists of the operator's image in a frame and a badge indicating the number of unread messages.
/// Tapping on this indicator will bring the user to the latest messages.
public struct UnreadMessageIndicatorStyle {
    /// Style of the badge in the top right corner that indicates the number of unread messages.
    public var badge: BadgeStyle

    /// Style of the operator's image that appears in the indicator's main frame.
    public var userImage: UserImageStyle

    ///
    /// - Parameters:
    ///   - badgeFont: Font of the text that appears on the badge that indicates the number of unread messages.
    ///   - badgeTextColor: Color of the text that appears on the badge that indicates the number of unread messages.
    ///   - badgeColor: Background color of the badge that indicates the number of unread messages.
    ///   - placeholderImage: Image that acts as a placeholder if the operator has no picture set.
    ///   - placeholderColor: Color of the placeholder's image if the operator has no picture set.
    ///   - placeholderBackgroundColor: Background color of the placeholder's image if the operator has no picture set.
    ///   - imageBackgroundColor: Background color of the operator's image. Visible when the operator's image contains transparent parts.
    public init(
        badgeFont: UIFont,
        badgeTextColor: UIColor,
        badgeColor: UIColor,
        placeholderImage: UIImage?,
        placeholderColor: UIColor,
        placeholderBackgroundColor: UIColor,
        imageBackgroundColor: UIColor,
        transferringImage: UIImage
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
            imageBackgroundColor: imageBackgroundColor,
            transferringImage: transferringImage
        )
    }
}
