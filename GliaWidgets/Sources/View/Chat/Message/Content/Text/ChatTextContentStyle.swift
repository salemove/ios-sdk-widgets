import UIKit

/// Style of a text message.
public class ChatTextContentStyle {
    /// Font of the message text.
    public var textFont: UIFont

    /// Color of the message text.
    public var textColor: UIColor

    /// Text style of the message text.
    public var textStyle: UIFont.TextStyle

    /// Background color of the view.
    public var backgroundColor: UIColor

    /// Corner radius of the view.
    public var cornerRadius: CGFloat

    /// Accessibility related properties.
    public var accessibility: Accessibility

    ///
    /// - Parameters:
    ///   - textFont: Font of the message text.
    ///   - textColor: Color of the message text.
    ///   - textStyle: Text style of the message text. Necessary for attributed strings.
    ///   - backgroundColor: Background color of the content view.
    ///   - accessibility: Accessibility related properties.
    ///
    public init(
        textFont: UIFont,
        textColor: UIColor,
        textStyle: UIFont.TextStyle,
        backgroundColor: UIColor,
        cornerRadius: CGFloat = 8.49,
        accessibility: Accessibility
    ) {
        self.textFont = textFont
        self.textColor = textColor
        self.textStyle = textStyle
        self.backgroundColor = backgroundColor
        self.cornerRadius = cornerRadius
        self.accessibility = accessibility
    }
}
