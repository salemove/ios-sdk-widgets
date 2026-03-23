extension ActionButtonStyle {
    /// Accessibility properties of ActionButtonStyle.
    public struct Accessibility: Equatable {
        /// Accessibility label.
        public var label: String

        /// Accessibility hint.
        public var hint: String

        /// Flag that provides font dynamic type by setting `adjustsFontForContentSizeCategory`
        /// for component that supports it.
        public var isFontScalingEnabled: Bool

        /// - Parameters:
        ///   - label: Accessibility label.
        ///   - hint: Accessibility hint.
        ///   - isFontScalingEnabled: Flag that provides font dynamic type by setting
        ///    `adjustsFontForContentSizeCategory` for component that supports it.
        public init(
            label: String,
            hint: String = "",
            isFontScalingEnabled: Bool
        ) {
            self.label = label
            self.hint = hint
            self.isFontScalingEnabled = isFontScalingEnabled
        }
    }
}

extension ActionButtonStyle.Accessibility {
    /// Accessibility is not supported intentionally.
    public static let unsupported = Self(
        label: "",
        hint: "",
        isFontScalingEnabled: false
    )
}
