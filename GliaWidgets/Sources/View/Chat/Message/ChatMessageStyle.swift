import UIKit

/// Base style of a chat message.
public class ChatMessageStyle {
    /// Style of the text content.
    public var text: ChatTextContentStyle

    /// Style of the image content.
    public var imageFile: ChatImageFileContentStyle

    /// Style of the downloadable file content.
    public var fileDownload: ChatFileDownloadStyle

    ///
    /// - Parameters:
    ///   - text: Style of the text content.
    ///   - imageFile: Style of the image content.
    ///   - fileDownload: Style of the downloadable file content.
    ///
    public init(
        text: ChatTextContentStyle,
        imageFile: ChatImageFileContentStyle,
        fileDownload: ChatFileDownloadStyle
    ) {
        self.text = text
        self.imageFile = imageFile
        self.fileDownload = fileDownload
    }
}
