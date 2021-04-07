import UIKit

/// Base style of a chat message.
public class ChatMessageStyle {
    /// Style of a text content.
    public var text: ChatTextContentStyle

    /// Style of a image content.
    public var imageFile: ChatImageFileContentStyle

    /// Style of a downloadable file content.
    public var fileDownload: ChatFileDownloadStyle

    ///
    /// - Parameters:
    ///   - text: Style of a text content.
    ///   - imageFile: Style of a image content.
    ///   - fileDownload: Style of a downloadable file content.
    ///
    public init(text: ChatTextContentStyle,
                imageFile: ChatImageFileContentStyle,
                fileDownload: ChatFileDownloadStyle) {
        self.text = text
        self.imageFile = imageFile
        self.fileDownload = fileDownload
    }
}
