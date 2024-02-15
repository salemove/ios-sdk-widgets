import UIKit

public extension Theme {
    /// Style of a visitor's message.
    struct SystemMessageStyle {
        /// Style of the message text.
        public var text: Text

        /// Style of the message background.
        public var background: Layer

        /// Style of the image content.
        public var imageFile: ChatImageFileContentStyle

        /// Style of the image content.
        public var fileDownload: ChatFileDownloadStyle

        /// Accessibility related properties.
        public var accessibility: Accessibility

        /// - Parameters:
        ///   - text: Style of the message text.
        ///   - background: Style of the message background.
        ///   - imageFile: Style of the image content.
        ///   - fileDownload: Style of the downloadable file content.
        ///   - accessibility: Accessibility related properties.
        ///
        public init(
            text: Text,
            background: Layer,
            imageFile: ChatImageFileContentStyle,
            fileDownload: ChatFileDownloadStyle,
            accessibility: Accessibility = .unsupported
        ) {
            self.text = text
            self.background = background
            self.imageFile = imageFile
            self.fileDownload = fileDownload
            self.accessibility = accessibility
        }
    }
}

extension Theme.SystemMessageStyle {
    func toOldSystemMessageStyle() -> SystemMessageStyle {
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
            fileDownload: fileDownload
        )
    }
}
