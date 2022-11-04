import UIKit

/// Style of an operator's message.
public class OperatorChatMessageStyle: ChatMessageStyle {
    /// Style of the operator's image.
    public var operatorImage: UserImageStyle

    ///
    /// - Parameters:
    ///   - text: Style of the text content.
    ///   - imageFile: Style of the image content.
    ///   - fileDownload: Style of the downloadable file content.
    ///   - operatorImage: Style of the operator's image.
    ///
    public init(
        text: ChatTextContentStyle,
        imageFile: ChatImageFileContentStyle,
        fileDownload: ChatFileDownloadStyle,
        operatorImage: UserImageStyle
    ) {
        self.operatorImage = operatorImage
        super.init(
            text: text,
            imageFile: imageFile,
            fileDownload: fileDownload
        )
    }

    func apply(configuration: RemoteConfiguration.MessageBalloon?) {
        configuration?.background?.cornerRadius
            .map { text.cornerRadius = $0 }

        configuration?.background?.color?.value
            .map { UIColor(hex: $0) }
            .first
            .map {
                text.backgroundColor = $0
                imageFile.backgroundColor = $0
            }

        UIFont.convertToFont(
            font: configuration?.text?.font,
            textStyle: text.textStyle
        ).map { text.textFont = $0 }

        configuration?.text?.foreground?.value
            .map { UIColor(hex: $0) }
            .first
            .map { text.textColor = $0 }

        fileDownload.apply(configuration: configuration?.file)
        operatorImage.apply(configuration: configuration?.userImage)
    }
}
