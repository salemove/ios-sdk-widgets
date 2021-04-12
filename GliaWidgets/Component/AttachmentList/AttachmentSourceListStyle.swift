import UIKit

/// Style of the list that contains the attachment sources. Appears in media upload menu popover.
public class AttachmentSourceListStyle {
    /// Items to show in the list.
    public var items: [AttachmentSourceItemStyle]

    /// Color of the seprator line.
    public var separatorColor: UIColor

    /// Background color of the view.
    public var backgroundColor: UIColor

    ///
    /// - Parameters:
    ///   - items: Items to show in the list.
    ///   - separatorColor: Color of the seprator line.
    ///   - backgroundColor: Background color of the view.
    ///
    public init(items: [AttachmentSourceItemStyle],
                separatorColor: UIColor,
                backgroundColor: UIColor) {
        self.items = items
        self.separatorColor = separatorColor
        self.backgroundColor = backgroundColor
    }
}
