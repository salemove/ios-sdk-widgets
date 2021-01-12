import UIKit

public struct MediaUpgradeActionStyle {
    public var title: String
    public var titleFont: UIFont
    public var titleColor: UIColor
    public var info: String
    public var infoFont: UIFont
    public var infoColor: UIColor
    public var borderColor: UIColor
    public var backgroundColor: UIColor
    public var icon: UIImage
    public var iconColor: UIColor

    public init(title: String,
                titleFont: UIFont,
                titleColor: UIColor,
                info: String,
                infoFont: UIFont,
                infoColor: UIColor,
                borderColor: UIColor,
                backgroundColor: UIColor,
                icon: UIImage,
                iconColor: UIColor) {
        self.title = title
        self.titleFont = titleFont
        self.titleColor = titleColor
        self.info = info
        self.infoFont = infoFont
        self.infoColor = infoColor
        self.borderColor = borderColor
        self.backgroundColor = backgroundColor
        self.icon = icon
        self.iconColor = iconColor
    }
}
