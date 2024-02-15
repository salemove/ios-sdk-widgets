import Foundation

/// Style of an upload list view.
public class MessageCenterFileUploadListStyle: Equatable {
    /// Style of an item.
    public var item: MessageCenterFileUploadStyle

    /// - Parameters:
    ///   - item: Style of an item.
    ///
    public init(item: MessageCenterFileUploadStyle) {
        self.item = item
    }
}
