import UIKit

public class VisitorChatMessageStyle: ChatMessageStyle {
    public var statusFont: UIFont
    public var statusColor: UIColor
    public var delivered: String

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
