import UIKit

public class ChatMessageStyle {
    public var text: ChatTextContentStyle
    public var imageDownload: ChatImageDownloadContentStyle

    public init(text: ChatTextContentStyle,
                imageDownload: ChatImageDownloadContentStyle) {
        self.text = text
        self.imageDownload = imageDownload
    }
}
