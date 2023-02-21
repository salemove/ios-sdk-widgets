import UIKit

extension SecureConversations.WelcomeStyle {
    /// Style for description showm in the welcome area.
    public struct SubtitleStyle: Equatable {
        /// Subtitle text value.
        public var text: String
        /// Subtitle font.
        public var font: UIFont
        /// Text style of the text.
        public var textStyle: UIFont.TextStyle
        /// Subtitle color.
        public var color: UIColor
        /// Accessibility related properties.
        public var accessibility: Accessibility

        /// - Parameters:
        ///   - text: Subtitle text value.
        ///   - font: Subtitle font.
        ///   - color: Subtitle color.
        ///   - accessibility: Accessibility related properties.
        public init(
            text: String,
            font: UIFont,
            textStyle: UIFont.TextStyle,
            color: UIColor,
            accessibility: Accessibility
        ) {
            self.text = text
            self.font = font
            self.textStyle = textStyle
            self.color = color
            self.accessibility = accessibility
        }

        /// Accessibility properties for SubtitleStyle.
        public struct Accessibility: Equatable {
            /// Flag that provides font dynamic type by setting `adjustsFontForContentSizeCategory` for component that supports it.
            public var isFontScalingEnabled: Bool

            /// - Parameter isFontScalingEnabled: Flag that provides font dynamic type by setting `adjustsFontForContentSizeCategory` for component that supports it.
            public init(isFontScalingEnabled: Bool) {
                self.isFontScalingEnabled = isFontScalingEnabled
            }

            /// Accessibility is not supported intentionally.
            public static let unsupported = Self(isFontScalingEnabled: false)
        }

        mutating func apply(
            configuration: RemoteConfiguration.Text?,
            assetBuilder: RemoteConfiguration.AssetsBuilder
        ) {
            UIFont.convertToFont(
                uiFont: assetBuilder.fontBuilder(configuration?.font),
                textStyle: textStyle
            ).unwrap { font = $0 }

            configuration?.foreground?.value
                .map { UIColor(hex: $0) }
                .first
                .unwrap { color = $0 }
        }
    }
}
