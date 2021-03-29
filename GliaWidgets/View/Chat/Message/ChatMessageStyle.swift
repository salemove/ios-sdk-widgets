import UIKit

public class ChatMessageStyle {
    public var text: ChatTextContentStyle
    public var imageFile: ChatImageFileContentStyle
    public var fileDownload: ChatFileDownloadStyle

    public init(text: ChatTextContentStyle,
                imageFile: ChatImageFileContentStyle,
                fileDownload: ChatFileDownloadStyle) {
        self.text = text
        self.imageFile = imageFile
        self.fileDownload = fileDownload
    }
}
