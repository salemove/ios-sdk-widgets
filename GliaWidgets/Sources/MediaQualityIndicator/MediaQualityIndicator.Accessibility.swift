import Foundation

extension MediaQualityIndicatorStyle {
    /// Accessibility properties for `Text`.
    public struct Accessibility: Equatable {
        /// Flag that provides font dynamic type by setting `adjustsFontForContentSizeCategory`
        /// for component that supports it.
        public var isFontScalingEnabled: Bool

        /// Accessibility label.
        public var label: String

        /// - Parameters:
        ///   - isFontScalingEnabled: Flag that provides font dynamic type by setting
        ///    `adjustsFontForContentSizeCategory` for component that supports it.
        ///
        public init(
            isFontScalingEnabled: Bool,
            label: String
        ) {
            self.isFontScalingEnabled = isFontScalingEnabled
            self.label = label
        }
    }
}

extension MediaQualityIndicatorStyle.Accessibility {
    /// Accessibility is not supported intentionally.
    public static let unsupported = Self(
        isFontScalingEnabled: false,
        label: Localization.Call.PoorConnection.banner
    )
}
