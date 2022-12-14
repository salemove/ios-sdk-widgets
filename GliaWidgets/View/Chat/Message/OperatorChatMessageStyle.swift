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

    func apply(
        configuration: RemoteConfiguration.MessageBalloon?,
        assetsBuilder: RemoteConfiguration.AssetsBuilder
    ) {
        configuration?.background?.cornerRadius
            .unwrap { text.cornerRadius = $0 }

        configuration?.background?.color?.value
            .map { UIColor(hex: $0) }
            .first
            .unwrap {
                text.backgroundColor = $0
                imageFile.backgroundColor = $0
            }

        UIFont.convertToFont(
            uiFont: assetsBuilder.fontBuilder(configuration?.text?.font),
            textStyle: text.textStyle
        ).unwrap { text.textFont = $0 }

        configuration?.text?.foreground?.value
            .map { UIColor(hex: $0) }
            .first
            .unwrap { text.textColor = $0 }

        fileDownload.apply(
            configuration: configuration?.file,
            assetsBuilder: assetsBuilder
        )
        operatorImage.apply(configuration: configuration?.userImage)
    }
}
