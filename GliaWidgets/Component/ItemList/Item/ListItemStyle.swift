import UIKit

public class ListItemStyle {
    public var kind: ListItemKind
    public var title: String
    public var titleFont: UIFont
    public var titleColor: UIColor
    public var icon: UIImage?
    public var iconColor: UIColor?

    public init(kind: ListItemKind,
                title: String,
                titleFont: UIFont,
                titleColor: UIColor,
                icon: UIImage?,
                iconColor: UIColor?) {
        self.kind = kind
        self.title = title
        self.titleFont = titleFont
        self.titleColor = titleColor
        self.icon = icon
        self.iconColor = iconColor
    }
}
