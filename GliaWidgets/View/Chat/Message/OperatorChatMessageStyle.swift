import UIKit

public class OperatorChatMessageStyle: ChatMessageStyle {
    public var operatorImage: UserImageStyle

    public init(text: ChatTextContentStyle,
                imageFile: ChatImageFileContentStyle,
                fileDownload: ChatFileDownloadStyle,
                operatorImage: UserImageStyle) {
        self.operatorImage = operatorImage
        super.init(text: text,
                   imageFile: imageFile,
                   fileDownload: fileDownload)
    }
}
