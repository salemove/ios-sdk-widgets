import UIKit

extension SecureConversations.WelcomeStyle.SubtitleStyle {
    /// Accessibility properties for SubtitleStyle.
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

extension SecureConversations.WelcomeStyle.SubtitleStyle.Accessibility {
    /// Accessibility is not supported intentionally.
    public static let unsupported = Self(isFontScalingEnabled: false)
}
