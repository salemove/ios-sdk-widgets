import UIKit

public class OperatorChatMessageStyle: ChatMessageStyle {
    public var operatorImage: UserImageStyle

    public init(text: ChatTextContentStyle,
                imageDownload: ChatImageDownloadContentStyle,
                operatorImage: UserImageStyle) {
        self.operatorImage = operatorImage
        super.init(text: text, imageDownload: imageDownload)
    }
}
