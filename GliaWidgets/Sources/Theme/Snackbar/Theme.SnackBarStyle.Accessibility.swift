import Foundation

extension Theme.SnackBarStyle {
    /// Accessibility properties for `Text`.
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

extension Theme.SnackBarStyle.Accessibility {
    /// Accessibility is not supported intentionally.
    public static let unsupported = Self(isFontScalingEnabled: false)
}
