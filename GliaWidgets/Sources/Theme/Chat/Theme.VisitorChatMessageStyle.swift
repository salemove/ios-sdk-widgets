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

        /// Style of the message error text.
        public var error: Text

        /// Text of the failed to deliver message status.
        public var failedToDeliver: String

        /// Accessibility related properties.
        public var accessibility: Accessibility

        /// - Parameters:
        ///   - text: Style of the message text.
        ///   - background: Style of the message background.
        ///   - imageFile: Style of the image content.
        ///   - fileDownload: Style of the downloadable file content.
        ///   - status: Style of the message status text.
        ///   - delivered: Text of the message delivered status.
        ///   - error: Style of the message error text.
        ///   - failedToDeliver: Text of the failed to deliver message status.
        ///   - accessibility: Accessibility related properties.
        ///
        public init(
            text: Text,
            background: Layer,
            imageFile: ChatImageFileContentStyle,
            fileDownload: ChatFileDownloadStyle,
            status: Text,
            delivered: String,
            // TODO: default value should be removed in 3.0.0 - MOB-3610
            error: Text = .init(
                color: "D11149",
                font: UIFont.systemFont(ofSize: 12, weight: .regular),
                textStyle: .caption1,
                accessibility: .init(isFontScalingEnabled: true)
            ),
            failedToDeliver: String = "",
            accessibility: Accessibility = .unsupported
        ) {
            self.text = text
            self.background = background
            self.imageFile = imageFile
            self.fileDownload = fileDownload
            self.status = status
            self.delivered = delivered
            self.error = error
            self.failedToDeliver = failedToDeliver
            self.accessibility = accessibility
        }
    }
}
