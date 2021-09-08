import UIKit

/// Style of an upload list view.
public class FileUploadListStyle {
    /// Style of an item.
    public var item: FileUploadStyle

    ///
    /// - Parameters:
    ///   - item: Style of an item.
    ///
    public init(item: FileUploadStyle) {
        self.item = item
    }
}
