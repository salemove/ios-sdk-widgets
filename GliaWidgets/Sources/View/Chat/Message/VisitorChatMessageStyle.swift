import UIKit

/// Deprecated. Style of a visitor's message.
@available(*, deprecated, message: "Deprecated, use ``Theme.VisitorMessageStyle`` instead.")
public class VisitorChatMessageStyle: ChatMessageStyle {
    /// Font of the message status text.
    public var statusFont: UIFont

    /// Color of the message status text.
    public var statusColor: UIColor

    /// Text style of the message status text.
    public var statusTextStyle: UIFont.TextStyle

    /// Text of the message delivered status.
    public var delivered: String

    /// Accessibility related properties.
    public var accessibility: Accessibility

    ///
    /// - Parameters:
    ///   - text: Style of the text content.
    ///   - imageFile: Style of the image content.
    ///   - fileDownload: Style of the downloadable file content.
    ///   - statusFont: Font of the message status text.
    ///   - statusColor: Color of the message status text.
    ///   - statusTextStyle: Text style of the message status text.
    ///   - delivered: Text of the message delivered status.
    ///   - accessibility: Accessibility related properties.
    ///
    public init(
        text: ChatTextContentStyle,
        imageFile: ChatImageFileContentStyle,
        fileDownload: ChatFileDownloadStyle,
        statusFont: UIFont,
        statusColor: UIColor,
        statusTextStyle: UIFont.TextStyle,
        delivered: String,
        accessibility: Accessibility = .unsupported
    ) {
        self.statusFont = statusFont
        self.statusColor = statusColor
        self.statusTextStyle = statusTextStyle
        self.delivered = delivered
        self.accessibility = accessibility
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

        UIFont.convertToFont(
            uiFont: assetsBuilder.fontBuilder(configuration?.status?.font),
            textStyle: statusTextStyle
        ).unwrap { statusFont = $0 }

        configuration?.status?.foreground?.value
            .map { UIColor(hex: $0) }
            .first
            .unwrap { statusColor = $0 }

        fileDownload.apply(
            configuration: configuration?.file,
            assetsBuilder: assetsBuilder
        )
    }

    func toNewVisitorMessageStyle() -> Theme.VisitorMessageStyle {
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
            status: .init(
                color: statusColor.hex,
                font: statusFont,
                textStyle: statusTextStyle,
                accessibility: .init(isFontScalingEnabled: text.accessibility.isFontScalingEnabled)
            ),
            delivered: delivered,
            accessibility: .init(
                value: text.accessibility.value,
                isFontScalingEnabled: text.accessibility.isFontScalingEnabled
            )
        )
    }
}
