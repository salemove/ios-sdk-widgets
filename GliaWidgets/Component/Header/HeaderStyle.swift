import UIKit

/// Style of a view's header (navigation bar).
public struct HeaderStyle {
    /// Font of the title text.
    public var titleFont: UIFont

    /// Color of the title text.
    public var titleColor: UIColor

    /// Background color of the view.
    public var backgroundColor: UIColor

    /// Style of the back button.
    public var backButton: HeaderButtonStyle

    /// Style of the queue closing button.
    public var closeButton: HeaderButtonStyle

    /// Style of the engagement ending button.
    public var endButton: ActionButtonStyle

    /// Style of the screen sharing ending button.
    public var endScreenShareButton: HeaderButtonStyle

    /// Accessibility related properties.
    public var accessibility: Accessibility

    ///
    /// - Parameters:
    ///   - titleFont: Font of the title text.
    ///   - titleColor: Color of the title text.
    ///   - backgroundColor: Background color of the view.
    ///   - backButton: Style of the back button.
    ///   - closeButton: Style of the queue closing button.
    ///   - endButton: Style of the engagement ending button.
    ///   - endScreenShareButton: Style of the screen sharing ending button.
    ///   - accessibility: Accessibility related properties.
    ///
    public init(
        titleFont: UIFont,
        titleColor: UIColor,
        backgroundColor: UIColor,
        backButton: HeaderButtonStyle,
        closeButton: HeaderButtonStyle,
        endButton: ActionButtonStyle,
        endScreenShareButton: HeaderButtonStyle,
        accessibility: Accessibility
    ) {
        self.titleFont = titleFont
        self.titleColor = titleColor
        self.backgroundColor = backgroundColor
        self.backButton = backButton
        self.closeButton = closeButton
        self.endButton = endButton
        self.endScreenShareButton = endScreenShareButton
        self.accessibility = accessibility
    }
}
