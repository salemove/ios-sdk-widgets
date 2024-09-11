import UIKit

/// Deprecated. Style of an operator's message.
@available(*, deprecated, message: "Deprecated, use ``Theme.OperatorMessageStyle`` instead.")
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

    func toNewOperatorMessageStyle() -> Theme.OperatorMessageStyle {
        .init(
            text: .init(
                color: text.textColor.hex,
                font: text.textFont,
                textStyle: text.textStyle,
                accessibility: .init(isFontScalingEnabled: text.accessibility.isFontScalingEnabled)
            ),
            background: .init(
                background: .fill(color: text.backgroundColor),
                borderColor: .clear, // <- Because OperatorChatMessageStyle does not have `borderColor`
                borderWidth: .zero, // <- Because OperatorChatMessageStyle does not have `borderWidth`
                cornerRadius: text.cornerRadius
            ),
            imageFile: imageFile,
            fileDownload: fileDownload,
            operatorImage: operatorImage,
            accessibility: .init(
                value: text.accessibility.value,
                isFontScalingEnabled: text.accessibility.isFontScalingEnabled
            )
        )
    }
}
