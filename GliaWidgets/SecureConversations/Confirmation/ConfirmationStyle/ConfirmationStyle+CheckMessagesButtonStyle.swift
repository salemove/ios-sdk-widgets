import UIKit

extension SecureConversations.ConfirmationStyle {
    /// Style for button to check messages.
    public struct CheckMessagesButtonStyle: Equatable {
        /// Title text of the button.
        public var title: String
        /// Font of the title.
        public var font: UIFont
        /// Color of the button title text.
        public var textColor: UIColor
        /// Background color of the button.
        public var backgroundColor: UIColor
        /// Accessibility related properties.
        public var accessibility: Accessibility

        /// - Parameters:
        ///   - title: Title text of the button.
        ///   - font: Font of the title.
        ///   - textColor: Color of the button title text.
        ///   - backgroundColor: Background color of the button.
        ///   - accessibility: Accessibility related properties.
        public init(
            title: String,
            font: UIFont,
            textColor: UIColor,
            backgroundColor: UIColor,
            accessibility: Accessibility
        ) {
            self.title = title
            self.font = font
            self.textColor = textColor
            self.backgroundColor = backgroundColor
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
    }
}
