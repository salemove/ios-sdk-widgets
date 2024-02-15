import UIKit

/// Style of an upload list view.
public class FileUploadListStyle: Equatable {
    /// Style of an item.
    public var item: FileUploadStyle

    /// - Parameters:
    ///   - item: Style of an item.
    ///
    public init(item: FileUploadStyle) {
        self.item = item
    }
}

extension FileUploadListStyle {
    static let initial: FileUploadListStyle = Theme().chatStyle.messageEntry.uploadList
}
