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

        ///
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

        mutating func apply(
            configuration: RemoteConfiguration.MessageBalloon?,
            assetsBuilder: RemoteConfiguration.AssetsBuilder
        ) {
            background.apply(configuration: configuration?.background)

            configuration?.background?.color?.value
                .map { UIColor(hex: $0) }
                .first
                .unwrap { imageFile.backgroundColor = $0 }

            text.apply(
                configuration: configuration?.text,
                assetsBuilder: assetsBuilder
            )
            status.apply(
                configuration: configuration?.status,
                assetsBuilder: assetsBuilder
            )

            fileDownload.apply(
                configuration: configuration?.file,
                assetsBuilder: assetsBuilder
            )
        }
    }
}

extension Theme.VisitorMessageStyle {
    /// Accessibility properties for VisitorMessageStyle.
    public struct Accessibility: Equatable {
        /// Accessibility value.
        public var value: String

        /// Flag that provides font dynamic type by setting `adjustsFontForContentSizeCategory` for component that supports it.
        public var isFontScalingEnabled: Bool

        ///
        /// - Parameters:
        ///   - value: Accessibility value.
        ///   - isFontScalingEnabled: Flag that provides font dynamic type by setting `adjustsFontForContentSizeCategory` for component that supports it.
        public init(
            value: String = "",
            isFontScalingEnabled: Bool
        ) {
            self.value = value
            self.isFontScalingEnabled = isFontScalingEnabled
        }

        /// Accessibility is not supported intentionally.
        public static let unsupported = Self(
            value: "",
            isFontScalingEnabled: false
        )
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
