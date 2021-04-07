import UIKit

/// Style of a operator's message.
public class OperatorChatMessageStyle: ChatMessageStyle {
    /// Style of the operator's image.
    public var operatorImage: UserImageStyle

    ///
    /// - Parameters:
    ///   - text: Style of a text content.
    ///   - imageFile: Style of a image content.
    ///   - fileDownload: Style of a downloadable file content.
    ///   - operatorImage: Style of the operator's image.
    ///
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
