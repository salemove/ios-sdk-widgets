import UIKit

/// Style of a view's header (navigation bar).
public struct HeaderStyle {
    /// Font of the title text.
    public var titleFont: UIFont

    /// Color of the title text.
    public var titleColor: UIColor

    /// Background color of the view.
    public var backgroundColor: UIColor
    public var backButton: HeaderButtonStyle
    public var closeButton: HeaderButtonStyle
    public var endButton: ActionButtonStyle
    public var endScreenShareButton: HeaderButtonStyle

    ///
    /// - Parameters:
    ///   - titleFont: Font of the title text.
    ///   - titleColor: Color of the title text.
    ///   - backgroundColor: Background color of the view.
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
