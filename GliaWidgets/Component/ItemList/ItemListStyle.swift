import UIKit

public class ItemListStyle {
    public var items: [ListItemStyle]
    public var separatorColor: UIColor
    public var backgroundColor: UIColor

    public init(items: [ListItemStyle],
                separatorColor: UIColor,
                backgroundColor: UIColor) {
        self.items = items
        self.separatorColor = separatorColor
        self.backgroundColor = backgroundColor
    }
}
