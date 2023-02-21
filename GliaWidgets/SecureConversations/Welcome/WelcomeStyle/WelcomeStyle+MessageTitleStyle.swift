import UIKit

extension SecureConversations.WelcomeStyle {
    /// Style for message title.
    public struct MessageTitleStyle: Equatable {
        /// Message title text.
        public var title: String
        /// Font of the message title.
        public var font: UIFont
        /// Text style of the text.
        public var textStyle: UIFont.TextStyle
        /// Color of the message title.
        public var color: UIColor
        /// Accessibility related properties.
        public var accessibility: Accessibility

        /// - Parameters:
        ///   - title: Message title text.
        ///   - font: Font of the message title.
        ///   - color: Color of the message title.
        public init(
            title: String,
            font: UIFont,
            textStyle: UIFont.TextStyle,
            color: UIColor,
            accessibility: Accessibility
        ) {
            self.title = title
            self.font = font
            self.textStyle = textStyle
            self.color = color
            self.accessibility = accessibility
        }

        /// Accessibility properties for MessageTitleStyle.
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
