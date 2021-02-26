import UIKit

public class ListItemStyle {
    public var title: String
    public var titleFont: UIFont
    public var titleColor: UIColor
    public var icon: UIImage?
    public var iconColor: UIColor?

    public init(title: String,
                titleFont: UIFont,
                titleColor: UIColor,
                icon: UIImage?,
                iconColor: UIColor?) {
        self.title = title
        self.titleFont = titleFont
        self.titleColor = titleColor
        self.icon = icon
        self.iconColor = iconColor
    }
}
