import UIKit

/// Style of a view's header (navigation bar).
public struct HeaderStyle {
    /// Font of the title text.
    public var titleFont: UIFont

    /// Color of the title text.
    public var titleColor: UIColor

    /// Background color of the view.
    public var backgroundColor: UIColor

    /// Back button style in the header.
    public var backButton: HeaderButtonStyle

    /// Close button style in the header.
    public var closeButton: HeaderButtonStyle

    /// Style of the engagement ending button.
    public var endButton: ActionButtonStyle

    /// Style of the screen sharing ending button.
    public var endScreenShareButton: HeaderButtonStyle

    ///
    /// - Parameters:
    ///   - titleFont: Font of the title text.
    ///   - titleColor: Color of the title text.
    ///   - backgroundColor: Background color of the view.
    ///   - backButton: Back button style in the header.
    ///   - closeButton: Close button style in the header.
    ///   - endButton: Style of the engagement ending button.
    ///   - endScreenShareButton: Style of the screen sharing ending button.
    ///
    public init(
        titleFont: UIFont,
        titleColor: UIColor,
        backgroundColor: UIColor,
        backButton: HeaderButtonStyle,
        closeButton: HeaderButtonStyle,
        endButton: ActionButtonStyle,
        endScreenShareButton: HeaderButtonStyle
    ) {
        self.titleFont = titleFont
        self.titleColor = titleColor
        self.backgroundColor = backgroundColor
        self.backButton = backButton
        self.closeButton = closeButton
        self.endButton = endButton
        self.endScreenShareButton = endScreenShareButton
    }
}
