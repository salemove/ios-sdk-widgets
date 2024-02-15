import Foundation

extension Theme.Button {
    /// Accessibility properties for button style.
    public struct Accessibility: Equatable {
        /// Accessibility label.
        public var label: String

        /// Flag that provides font dynamic type by setting `adjustsFontForContentSizeCategory` 
        /// for component that supports it.
        public var isFontScalingEnabled: Bool

        /// - Parameters:
        ///   - label: Accessibility label.
        ///   - isFontScalingEnabled: Flag that provides font dynamic type by setting 
        ///    `adjustsFontForContentSizeCategory` for component that supports it.
        ///
        public init(
            label: String,
            isFontScalingEnabled: Bool
        ) {
            self.label = label
            self.isFontScalingEnabled = isFontScalingEnabled
        }
    }
}

extension Theme.Button.Accessibility {
    /// Accessibility is not supported intentionally.
    public static let unsupported = Self(
        label: "",
        isFontScalingEnabled: false
    )
}
