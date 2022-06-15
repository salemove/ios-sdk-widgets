import UIKit

/// Style of an attachment source list item.
public class AttachmentSourceItemStyle {
    /// Kind of an item shown in the attachment source list view (e.g. Photo Library, Take Photo or Browse).
    public var kind: AtttachmentSourceItemKind

    /// Title of the attachment source list item (e.g. "Take Photo").
    public var title: String

    /// Font of the title. Default is `bodyText`, i.e. Roboto Regular 16.
    public var titleFont: UIFont

    /// Color of the title.
    public var titleColor: UIColor

    /// Icon of the item. Default is one of three icons (Take Photo, Photo Library or Browse) corresponding to the kind of attachment.
    public var icon: UIImage?

    /// Color of the icon.
    public var iconColor: UIColor?

    /// Accessibility related properties.
    public var accessibility: Accessibility

    ///
    /// - Parameters:
    ///   - kind: Kind of an item shown in the attachment source list view (e.g. Photo Library, Take Photo or Browse).
    ///   - title: Title of the attachment source list item (e.g. "Take Photo").
    ///   - titleFont: Font of the title. Default is `bodyText`, i.e. Roboto Regular 16.
    ///   - titleColor: Color of the title.
    ///   - icon: Icon of the item. Default is one of three icons (Take Photo, Photo Library or Browse) corresponding to the kind of attachment.
    ///   - iconColor: Color of the icon.
    ///   - accessibility: Accessibility related properties.
    ///
    public init(
        kind: AtttachmentSourceItemKind,
        title: String,
        titleFont: UIFont,
        titleColor: UIColor,
        icon: UIImage?,
        iconColor: UIColor?,
        accessibility: Accessibility
    ) {
        self.kind = kind
        self.title = title
        self.titleFont = titleFont
        self.titleColor = titleColor
        self.icon = icon
        self.iconColor = iconColor
        self.accessibility = accessibility
    }
}
