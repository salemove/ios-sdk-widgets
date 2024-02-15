import UIKit

extension SecureConversations.WelcomeStyle.CheckMessagesButtonStyle {
    /// Accessibility properties for CheckMessagesButtonStyle.
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
            label: String,
            hint: String
        ) {
            self.isFontScalingEnabled = isFontScalingEnabled
            self.label = label
            self.hint = hint
        }
    }
}

extension SecureConversations.WelcomeStyle.CheckMessagesButtonStyle.Accessibility {
    /// Accessibility is not supported intentionally.
    public static let unsupported = Self(
        isFontScalingEnabled: false,
        label: "",
        hint: ""
    )
}
