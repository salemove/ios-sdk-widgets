import UIKit

/// Style of a visitor's message.
public class VisitorChatMessageStyle: ChatMessageStyle {
    /// Font of the message's status text.
    public var statusFont: UIFont

    /// Color of the message's status text.
    public var statusColor: UIColor

    /// Text of the message's delivered status.
    public var delivered: String

    ///
    /// - Parameters:
    ///   - text: Style of a text content.
    ///   - imageFile: Style of a image content.
    ///   - fileDownload: Style of a downloadable file content.
    ///   - statusFont: Font of the message's status text.
    ///   - statusColor: Color of the message's status text.
    ///   - delivered: Text of the message's delivered status.
    ///
    public init(text: ChatTextContentStyle,
                imageFile: ChatImageFileContentStyle,
                fileDownload: ChatFileDownloadStyle,
                statusFont: UIFont,
                statusColor: UIColor,
                delivered: String) {
        self.statusFont = statusFont
        self.statusColor = statusColor
        self.delivered = delivered
        super.init(text: text,
                   imageFile: imageFile,
                   fileDownload: fileDownload)
    }
}
