import UIKit

/// Style of the call upgrade view. Shown after engagement is upgraded to a call.
public class ChatCallUpgradeStyle {
    /// An icon indicating upgraded engagement kind.
    public var icon: UIImage

    /// Color of the icon image.
    public var iconColor: UIColor

    /// Text to display in the view.
    public var text: String

    /// Font of the text.
    public var textFont: UIFont

    /// Color of the text.
    public var textColor: UIColor

    /// Font of the duration counter text.
    public var durationFont: UIFont

    /// Color of the duration counter text.
    public var durationColor: UIColor

    /// Border color of the view.
    public var borderColor: UIColor

    ///
    /// - Parameters:
    ///   - icon: An icon indicating upgraded engagement kind.
    ///   - iconColor: Color of the icon image.
    ///   - text: Text to display in the view.
    ///   - textFont: Font of the text.
    ///   - textColor: Color of the text.
    ///   - durationFont: Font of the duration counter text.
    ///   - durationColor: Color of the duration counter text.
    ///   - borderColor: Border color of the view.
    ///
    public init(
        icon: UIImage,
        iconColor: UIColor,
        text: String,
        textFont: UIFont,
        textColor: UIColor,
        durationFont: UIFont,
        durationColor: UIColor,
        borderColor: UIColor
    ) {
        self.icon = icon
        self.iconColor = iconColor
        self.text = text
        self.textFont = textFont
        self.textColor = textColor
        self.durationFont = durationFont
        self.durationColor = durationColor
        self.borderColor = borderColor
    }
}
