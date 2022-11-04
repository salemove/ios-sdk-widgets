import UIKit

/// Style of the list that contains the chat attachment sources. Appears in the media upload menu popover in the message input area in chat.
public class AttachmentSourceListStyle {
    /// Possible attachment sources to show, for example: camera, photo gallery or local file system.
    public var items: [AttachmentSourceItemStyle]

    /// Color of a separator line between different attachment source items.
    public var separatorColor: UIColor

    /// Background color of the view.
    public var backgroundColor: UIColor

    ///
    /// - Parameters:
    ///   - items: Possible attachment sources to show, for example: camera, photo gallery or local file system.
    ///   - separatorColor: Color of a separator line between different attachment source items.
    ///   - backgroundColor: Background color of the view.
    ///
    public init(
        items: [AttachmentSourceItemStyle],
        separatorColor: UIColor,
        backgroundColor: UIColor
    ) {
        self.items = items
        self.separatorColor = separatorColor
        self.backgroundColor = backgroundColor
    }

    func apply(configuration: RemoteConfiguration.AttachmentSourceList?) {
        configuration?.separator?.value
            .map { UIColor(hex: $0) }
            .first
            .unwrap { separatorColor = $0 }

        configuration?.background?.value
            .map { UIColor(hex: $0) }
            .first
            .unwrap { backgroundColor = $0 }

        configuration?.items?.forEach { item in
            let sourceType = AttachmentSourceItemKind(rawValue: item.type.rawValue)
            items.first(where: { $0.kind == sourceType })?
                .apply(configuration: item)
        }
    }
}
