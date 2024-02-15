import UIKit

extension Theme.SystemMessageStyle {
    /// Accessibility properties for `SystemMessageStyle`.
    public struct Accessibility: Equatable {
        /// Accessibility value
        public var value: String

        /// Flag that provides font dynamic type by setting `adjustsFontForContentSizeCategory` 
        /// for component that supports it.
        public var isFontScalingEnabled: Bool

        /// - Parameters:
        ///   - value: Accessibility value
        ///   - isFontScalingEnabled: Flag that provides font dynamic type by setting 
        ///    `adjustsFontForContentSizeCategory` for component that supports it.
        ///
        public init(
            value: String = "",
            isFontScalingEnabled: Bool
        ) {
            self.value = value
            self.isFontScalingEnabled = isFontScalingEnabled
        }
    }
}

extension Theme.SystemMessageStyle.Accessibility {
    /// Accessibility is not supported intentionally.
    public static let unsupported = Self(
        value: "",
        isFontScalingEnabled: false
    )
}
