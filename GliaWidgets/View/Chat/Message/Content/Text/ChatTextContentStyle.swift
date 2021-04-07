import UIKit

/// Style of a text message.
public class ChatTextContentStyle {
    /// Font of the message text.
    public var textFont: UIFont

    /// Color of the message text.
    public var textColor: UIColor

    /// Background color of the view.
    public var backgroundColor: UIColor

    ///
    /// - Parameters:
    ///   - textFont: Font of the message text.
    ///   - textColor: Color of the message text.
    ///   - backgroundColor: Background color of the content view.
    ///
    public init(textFont: UIFont,
                textColor: UIColor,
                backgroundColor: UIColor) {
        self.textFont = textFont
        self.textColor = textColor
        self.backgroundColor = backgroundColor
    }
}
