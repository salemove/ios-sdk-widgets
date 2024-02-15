import UIKit

public extension Theme {
    /// Style of a visitor's message.
    struct VisitorMessageStyle {
        /// Style of the message text.
        public var text: Text

        /// Style of the message background.
        public var background: Layer

        /// Style of the image content.
        public var imageFile: ChatImageFileContentStyle

        /// Style of the image content.
        public var fileDownload: ChatFileDownloadStyle

        /// Style of the message status text.
        public var status: Text

        /// Text of the message delivered status.
        public var delivered: String

        /// Accessibility related properties.
        public var accessibility: Accessibility

        /// - Parameters:
        ///   - text: Style of the message text.
        ///   - background: Style of the message background.
        ///   - imageFile: Style of the image content.
        ///   - fileDownload: Style of the downloadable file content.
        ///   - status: Style of the message status text.
        ///   - delivered: Text of the message delivered status.
        ///   - accessibility: Accessibility related properties.
        ///
        public init(
            text: Text,
            background: Layer,
            imageFile: ChatImageFileContentStyle,
            fileDownload: ChatFileDownloadStyle,
            status: Text,
            delivered: String,
            accessibility: Accessibility = .unsupported
        ) {
            self.text = text
            self.background = background
            self.imageFile = imageFile
            self.fileDownload = fileDownload
            self.status = status
            self.delivered = delivered
            self.accessibility = accessibility
        }
    }
}

extension Theme.VisitorMessageStyle {
    func toOldVisitorMessageStyle() -> VisitorChatMessageStyle {
        .init(
            text: .init(
                textFont: text.font,
                textColor: UIColor(hex: text.color),
                textStyle: text.textStyle,
                backgroundColor: background.background?.color ?? .clear,
                cornerRadius: background.cornerRadius,
                accessibility: .init(
                    value: accessibility.value,
                    isFontScalingEnabled: accessibility.isFontScalingEnabled
                )
            ),
            imageFile: imageFile,
            fileDownload: fileDownload,
            statusFont: status.font,
            statusColor: UIColor(hex: status.color),
            statusTextStyle: status.textStyle,
            delivered: delivered,
            accessibility: .init(isFontScalingEnabled: accessibility.isFontScalingEnabled)
        )
    }
}
