import UIKit

extension SecureConversations.WelcomeStyle.MessageTextViewNormalStyle {
    /// Accessibility properties for `MessageTextViewNormalStyle`.
    public struct Accessibility: Equatable {
        /// Flag that provides font dynamic type by setting `adjustsFontForContentSizeCategory` 
        /// for component that supports it.
        public var isFontScalingEnabled: Bool

        /// - Parameters:
        ///   - isFontScalingEnabled: Flag that provides font dynamic type by setting 
        ///    `adjustsFontForContentSizeCategory` for component that supports it.
        ///
        public init(isFontScalingEnabled: Bool) {
            self.isFontScalingEnabled = isFontScalingEnabled
        }
    }
}

extension SecureConversations.WelcomeStyle.MessageTextViewNormalStyle.Accessibility {
    /// Accessibility is not supported intentionally.
    public static let unsupported = Self(isFontScalingEnabled: false)
}
