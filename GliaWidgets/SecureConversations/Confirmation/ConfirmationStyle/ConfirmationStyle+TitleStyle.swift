import UIKit

extension SecureConversations.ConfirmationStyle {
    /// Style for title shown in the confirmation area.
    public struct TitleStyle: Equatable {
        /// Title text value.
        public var text: String
        /// Title font.
        public var font: UIFont
        /// Title color.
        public var color: UIColor
        /// Accessibility related properties.
        public var accessibility: Accessibility

        /// Accessibility properties for TitleStyle.
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

        /// - Parameters:
        ///   - text: Title text value.
        ///   - font: Title font.
        ///   - color: Title color.
        ///   - accessibility: Accessibility related properties.
        public init(
            text: String,
            font: UIFont,
            color: UIColor,
            accessibility: Accessibility
        ) {
            self.text = text
            self.font = font
            self.color = color
            self.accessibility = accessibility
        }
    }
}
