import UIKit

/// Style of item's list.
public class ItemListStyle {
    /// Items to show in list.
    public var items: [ListItemStyle]

    /// Color of the seprator line.
    public var separatorColor: UIColor

    /// Background color of the view.
    public var backgroundColor: UIColor

    ///
    /// - Parameters:
    ///   - items: Items to show in list.
    ///   - separatorColor: Color of the seprator line.
    ///   - backgroundColor: Background color of the view.
    ///
    public init(items: [ListItemStyle],
                separatorColor: UIColor,
                backgroundColor: UIColor) {
        self.items = items
        self.separatorColor = separatorColor
        self.backgroundColor = backgroundColor
    }
}
