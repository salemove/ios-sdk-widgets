import UIKit

extension SecureConversations.WelcomeStyle {
    /// Style for button to check messages.
    public struct CheckMessagesButtonStyle: Equatable {
        /// Button title.
        public var title: String
        /// Font of the button title.
        public var font: UIFont
        /// Text style of the text.
        public var textStyle: UIFont.TextStyle
        /// Color of the button title.
        public var color: UIColor
        /// Accessibility related properties.
        public var accessibility: Accessibility

        /// - Parameters:
        ///   - title: Button title.
        ///   - font: Font of the button title.
        ///   - color: Color of the button title.
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

        /// Accessibility properties for CheckMessagesButtonStyle.
        public struct Accessibility: Equatable {
            /// Flag that provides font dynamic type by setting `adjustsFontForContentSizeCategory` for component that supports it.
            public var isFontScalingEnabled: Bool
            /// Accessibility label.
            public var label: String
            /// Accessibility hint.
            public var hint: String

            /// - Parameters:
            ///   - isFontScalingEnabled: Flag that provides font dynamic type by setting
            ///    `adjustsFontForContentSizeCategory` for component that supports it.
            ///   - label: Accessibility label.
            ///   - hint: Accessibility hint.
            public init(
                isFontScalingEnabled: Bool,
                label: String,
                hint: String
            ) {
                self.isFontScalingEnabled = isFontScalingEnabled
                self.label = label
                self.hint = hint
            }

            /// Accessibility is not supported intentionally.
            public static let unsupported = Self(
                isFontScalingEnabled: false,
                label: "",
                hint: ""
            )
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
