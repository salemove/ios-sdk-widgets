import UIKit

public class ChatCallUpgradeStyle {
    public var icon: UIImage
    public var iconColor: UIColor
    public var text: String
    public var textFont: UIFont
    public var textColor: UIColor
    public var durationFont: UIFont
    public var durationColor: UIColor
    public var borderColor: UIColor

    public init(icon: UIImage,
                iconColor: UIColor,
                text: String,
                textFont: UIFont,
                textColor: UIColor,
                durationFont: UIFont,
                durationColor: UIColor,
                borderColor: UIColor) {
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
