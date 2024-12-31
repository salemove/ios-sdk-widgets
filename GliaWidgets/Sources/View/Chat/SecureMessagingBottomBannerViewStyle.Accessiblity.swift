import Foundation

extension SecureMessagingBottomBannerViewStyle {
    /// Accessibility properties for SecureMessagingBottomBannerViewStyle.
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

extension SecureMessagingBottomBannerViewStyle.Accessibility {
    /// Accessibility is not supported intentionally.
    public static let unsupported = Self(
        isFontScalingEnabled: false
    )
}
