import UIKit

extension SecureConversations.WelcomeStyle.FilePickerButtonStyle {
    /// Accessibility properties for FilePickerButtonStyle.
    public struct Accessibility: Equatable {
        /// Flag that provides font dynamic type by setting `adjustsFontForContentSizeCategory` 
        /// for component that supports it.
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
        ///
        public init(
            isFontScalingEnabled: Bool,
            accessibilityLabel: String,
            accessibilityHint: String
        ) {
            self.isFontScalingEnabled = isFontScalingEnabled
            self.label = accessibilityLabel
            self.hint = accessibilityHint
        }
    }
}

extension SecureConversations.WelcomeStyle.FilePickerButtonStyle.Accessibility {
    /// Accessibility is not supported intentionally.
    public static let unsupported = Self(
        isFontScalingEnabled: false,
        accessibilityLabel: "",
        accessibilityHint: ""
    )
}
