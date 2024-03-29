import UIKit

/// Deprecated. Style of a system message.
@available(*, deprecated, message: "Deprecated, use ``Theme.SystemMessageStyle`` instead.")
final public class SystemMessageStyle: ChatMessageStyle {
    /// - Parameters:
    ///   - text: Style of the text content.
    ///   - imageFile: Style of the image content.
    ///   - fileDownload: Style of the downloadable file content.
    override public init(
        text: ChatTextContentStyle,
        imageFile: ChatImageFileContentStyle,
        fileDownload: ChatFileDownloadStyle
    ) {
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
            }

        UIFont.convertToFont(
            uiFont: assetsBuilder.fontBuilder(configuration?.text?.font),
            textStyle: text.textStyle
        ).unwrap { text.textFont = $0 }

        configuration?.text?.foreground?.value
            .map { UIColor(hex: $0) }
            .first
            .unwrap { text.textColor = $0 }
    }

    func toNewSystemMessageStyle() -> Theme.SystemMessageStyle {
        .init(
            text: .init(
                color: text.textColor.hex,
                font: text.textFont,
                textStyle: text.textStyle,
                alignment: .center,
                accessibility: .init(isFontScalingEnabled: text.accessibility.isFontScalingEnabled)
            ),
            background: .init(
                background: .fill(color: text.backgroundColor),
                borderColor: .clear, // <- Because SystemMessageStyle does not have `borderColor`
                borderWidth: .zero, // <- Because SystemMessageStyle does not have `borderWidth`
                cornerRadius: text.cornerRadius
            ),
            imageFile: imageFile,
            fileDownload: fileDownload,
            accessibility: .init(
                value: text.accessibility.value,
                isFontScalingEnabled: text.accessibility.isFontScalingEnabled
            )
        )
    }
}
