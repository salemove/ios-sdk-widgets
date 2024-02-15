import UIKit
/// Style of a bubble that represents a call or the entirety of Widgets when they are minimized.
public class BubbleStyle {
    /// Style of a user's image shown in the bubble.
    public var userImage: UserImageStyle

    /// Style of a badge shown on the bubble.
    public var badge: BadgeStyle?

    /// Style of a visitor's on hold state overlay.
    public var onHoldOverlay: OnHoldOverlayStyle

	/// Accessibility related properties.
    public var accessibility: Accessibility

    /// - Parameters:
    ///   - userImage: Style of a user's image shown in the bubble.
    ///   - badge: Style of a badge shown on the bubble.
    ///   - onHoldOverlay: Style of a visitor's on hold state overlay.
    ///   - accessibility: Accessibility related properties.
    ///
    public init(
        userImage: UserImageStyle,
        badge: BadgeStyle? = nil,
        onHoldOverlay: OnHoldOverlayStyle = .bubble,
        accessibility: Accessibility = .unsupported
    ) {
        self.userImage = userImage
        self.badge = badge
        self.onHoldOverlay = onHoldOverlay
        self.accessibility = accessibility
    }
}
