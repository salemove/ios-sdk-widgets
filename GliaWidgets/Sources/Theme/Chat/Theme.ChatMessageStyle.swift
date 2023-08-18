import UIKit

extension Theme {
    /// Internal base style of a chat message.
    struct ChatMessageStyle {
        /// Style of the message text.
        let text: Text
        /// Style of the message background.
        let background: Layer
        /// Style of the image content.
        let imageFile: ChatImageFileContentStyle
        /// Style of the image content.
        let fileDownload: ChatFileDownloadStyle
        /// Accessibility related properties.
        let accessibility: Accessibility

        ///
        /// - Parameters:
        ///   - text: Style of the message text.
        ///   - background: Style of the message background.
        ///   - imageFile: Style of the image content.
        ///   - fileDownload: Style of the downloadable file content.
        ///   - accessibility: Accessibility related properties.
        ///
        init(
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

extension Theme.ChatMessageStyle {
    /// Accessibility properties for ChatMessageStyle.
    struct Accessibility: Equatable {
        /// Accessibility value.
        var value: String
        /// Flag that provides font dynamic type by setting `adjustsFontForContentSizeCategory` for component that supports it.
        var isFontScalingEnabled: Bool

        ///
        /// - Parameters:
        ///   - value: Accessibility value.
        ///   - isFontScalingEnabled: Flag that provides font dynamic type by setting `adjustsFontForContentSizeCategory` for component that supports it.
        init(
            value: String = "",
            isFontScalingEnabled: Bool
        ) {
            self.value = value
            self.isFontScalingEnabled = isFontScalingEnabled
        }

        /// Accessibility is not supported intentionally.
        static let unsupported = Self(
            value: "",
            isFontScalingEnabled: false
        )
    }
}
