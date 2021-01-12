import UIKit

public struct MediaUpgradeStyle {
    public var title: String
    public var titleFont: UIFont
    public var titleColor: UIColor
    public var backgroundColor: UIColor
    public var closeButtonColor: UIColor
    public var audioAction: MediaUpgradeActionStyle
    public var phoneAction: MediaUpgradeActionStyle

    public init(title: String,
                titleFont: UIFont,
                titleColor: UIColor,
                backgroundColor: UIColor,
                closeButtonColor: UIColor,
                audioAction: MediaUpgradeActionStyle,
                phoneAction: MediaUpgradeActionStyle) {
        self.title = title
        self.titleFont = titleFont
        self.titleColor = titleColor
        self.backgroundColor = backgroundColor
        self.closeButtonColor = closeButtonColor
        self.audioAction = audioAction
        self.phoneAction = phoneAction
    }
}
