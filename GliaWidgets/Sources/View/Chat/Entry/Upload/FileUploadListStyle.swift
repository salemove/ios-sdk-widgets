import UIKit

/// Style of an upload list view.
public class FileUploadListStyle: Equatable {
    /// Style of an item.
    public var item: FileUploadStyle

    ///
    /// - Parameters:
    ///   - item: Style of an item.
    ///
    public init(item: FileUploadStyle) {
        self.item = item
    }

    func apply(
        configuration: RemoteConfiguration.FileUploadBar?,
        assetsBuilder: RemoteConfiguration.AssetsBuilder
    ) {
        item.apply(
            configuration: configuration,
            assetsBuilder: assetsBuilder
        )
    }
}

extension FileUploadListStyle {
    public static func == (lhs: FileUploadListStyle, rhs: FileUploadListStyle) -> Bool {
        lhs.item == rhs.item
    }
}

extension FileUploadListStyle {
    static let initial: FileUploadListStyle = Theme().chatStyle.messageEntry.uploadList
}

#if DEBUG
extension FileUploadListStyle {
    static let mock: FileUploadListStyle = .initial
}
#endif

/// Style of an upload list view.
public class MessageCenterFileUploadListStyle: Equatable {
    /// Style of an item.
    public var item: MessageCenterFileUploadStyle

    ///
    /// - Parameters:
    ///   - item: Style of an item.
    ///
    public init(item: MessageCenterFileUploadStyle) {
        self.item = item
    }

    func apply(
        configuration: RemoteConfiguration.FileUploadBar?,
        assetsBuilder: RemoteConfiguration.AssetsBuilder
    ) {
        item.apply(
            configuration: configuration,
            assetsBuilder: assetsBuilder
        )
    }
}

extension MessageCenterFileUploadListStyle {
    public static func == (
        lhs: MessageCenterFileUploadListStyle,
        rhs: MessageCenterFileUploadListStyle
    ) -> Bool {
        lhs.item == rhs.item
    }
}
