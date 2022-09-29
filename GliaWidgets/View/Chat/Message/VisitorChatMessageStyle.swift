import UIKit

/// Style of a visitor's message.
public class VisitorChatMessageStyle: ChatMessageStyle {
    /// Font of the message status text.
    public var statusFont: UIFont

    /// Color of the message status text.
    public var statusColor: UIColor

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
    ///   - delivered: Text of the message delivered status.
    ///   - accessibility: Accessibility related properties.
    ///
    public init(
        text: ChatTextContentStyle,
        imageFile: ChatImageFileContentStyle,
        fileDownload: ChatFileDownloadStyle,
        statusFont: UIFont,
        statusColor: UIColor,
        delivered: String,
        accessibility: Accessibility = .unsupported
    ) {
        self.statusFont = statusFont
        self.statusColor = statusColor
        self.delivered = delivered
        self.accessibility = accessibility
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

        configuration?.text?.font?.size
            .map { text.textFont = Font.regular($0) }

        configuration?.text?.foreground?.value
            .map { UIColor(hex: $0) }
            .first
            .map { text.textColor = $0 }

        configuration?.status?.font?.size
            .map { statusFont = Font.regular($0) }

        configuration?.status?.foreground?.value
            .map { UIColor(hex: $0) }
            .first
            .map { statusColor = $0 }

        fileDownload.apply(configuration: configuration?.file)
    }
}
