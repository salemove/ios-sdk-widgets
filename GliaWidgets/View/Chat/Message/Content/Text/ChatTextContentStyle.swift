import UIKit

/// Style of a text message.
public class ChatTextContentStyle {
    /// Font of the message text.
    public var textFont: UIFont

    /// Color of the message text.
    public var textColor: UIColor

    /// Background color of the view.
    public var backgroundColor: UIColor

    /// Accessibility related properties.
    public var accessibility: Accessibility

    ///
    /// - Parameters:
    ///   - textFont: Font of the message text.
    ///   - textColor: Color of the message text.
    ///   - backgroundColor: Background color of the content view.
    ///   - accessibility: Accessibility related properties.
    ///
    public init(
        textFont: UIFont,
        textColor: UIColor,
        backgroundColor: UIColor,
        accessibility: Accessibility
    ) {
        self.textFont = textFont
        self.textColor = textColor
        self.backgroundColor = backgroundColor
        self.accessibility = accessibility
    }
}
