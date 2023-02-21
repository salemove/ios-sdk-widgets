import UIKit

extension SecureConversations.WelcomeStyle {
    /// Style for message warning section.
    public struct MessageWarningStyle: Equatable {
        /// Color of the warning text.
        public var textColor: UIColor
        /// Font of the warning text.
        public var textFont: UIFont
        /// Text style of the text.
        public var textStyle: UIFont.TextStyle
        /// Color of the warning icon image.
        public var iconColor: UIColor
        /// Text for the message limit warning.
        public var messageLengthLimitText: String
        /// Accessibility related properties.
        public var accessibility: Accessibility

        /// - Parameters:
        ///   - textColor: Color of the warning text.
        ///   - textFont: Font of the warning text.
        ///   - iconColor: Color of the warning icon image.
        ///   - messageLengthLimitText: Text for the message limit warning.
        public init(
            textColor: UIColor,
            textFont: UIFont,
            textStyle: UIFont.TextStyle,
            iconColor: UIColor,
            messageLengthLimitText: String,
            accessibility: Accessibility
        ) {
            self.textColor = textColor
            self.textFont = textFont
            self.textStyle = textStyle
            self.iconColor = iconColor
            self.messageLengthLimitText = messageLengthLimitText
            self.accessibility = accessibility
        }

        /// Accessibility properties for MessageWarningStyle.
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
            textConfiguration: RemoteConfiguration.Text?,
            iconConfiguration: RemoteConfiguration.Color?,
            assetBuilder: RemoteConfiguration.AssetsBuilder
        ) {
            UIFont.convertToFont(
                uiFont: assetBuilder.fontBuilder(textConfiguration?.font),
                textStyle: textStyle
            ).unwrap { textFont = $0 }

            iconConfiguration?.value
                .map { UIColor(hex: $0) }
                .first
                .unwrap { iconColor = $0 }

            textConfiguration?.foreground?.value
                .map { UIColor(hex: $0) }
                .first
                .unwrap { textColor = $0 }
        }
    }
}
