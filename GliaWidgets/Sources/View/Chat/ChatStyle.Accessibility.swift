extension ChatStyle {
    /// Accessibility properties for ChatStyle.
    public struct Accessibility: Equatable {
        /// Localized 'operator' to be used in case if operator name is not provided for accessibility label.
        public var `operator`: String

        /// Localized visitor name or reference to be used for accessibility label.
        public var visitor: String

        /// Flag that provides font dynamic type by setting `adjustsFontForContentSizeCategory` 
        /// for component that supports it.
        public var isFontScalingEnabled: Bool

        /// - Parameters:
        ///   - operator: Localized 'operator' to be used in case if operator name is not 
        ///     provided for accessibility label.
        ///   - visitor: Localized visitor name or reference to be used for accessibility label.
        ///   - isFontScalingEnabled: Flag that provides font dynamic type by setting 
        ///   `adjustsFontForContentSizeCategory` for component that supports it.
        ///
        public init(
            operator: String,
            visitor: String,
            isFontScalingEnabled: Bool
        ) {
            self.operator = `operator`
            self.visitor = visitor
            self.isFontScalingEnabled = isFontScalingEnabled
        }
    }
}

extension ChatStyle.Accessibility {
    /// Accessibility is not supported intentionally.
    public static let unsupported = Self(
        operator: "",
        visitor: "",
        isFontScalingEnabled: false
    )
}
