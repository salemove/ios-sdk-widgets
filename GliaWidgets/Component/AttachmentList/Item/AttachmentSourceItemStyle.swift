import UIKit

/// Style of an attachment source list item.
public class AttachmentSourceItemStyle {
    /// Kind of an item.
    public var kind: AtttachmentSourceItemKind

    /// Title of the item.
    public var title: String

    /// Font of the title.
    public var titleFont: UIFont

    /// Color of the title.
    public var titleColor: UIColor

    /// Icon of the item.
    public var icon: UIImage?

    /// Color of the icon.
    public var iconColor: UIColor?

    ///
    /// - Parameters:
    ///   - kind: Kind of an item.
    ///   - title: Title of the item.
    ///   - titleFont: Font of the title.
    ///   - titleColor: Color of the title.
    ///   - icon: Icon of the item.
    ///   - iconColor: Color of the icon.
    ///
    public init(kind: AtttachmentSourceItemKind,
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
