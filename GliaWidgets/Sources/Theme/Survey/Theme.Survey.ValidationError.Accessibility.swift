public extension Theme.SurveyStyle.ValidationError {
    /// Accessibility properties for ValidationError style.
    struct Accessibility {
        /// Accessibility label.
        public var label: String

        /// Flag that provides font dynamic type by setting `adjustsFontForContentSizeCategory` 
        /// for component that supports it.
        public var isFontScalingEnabled: Bool

        /// - Parameters:
        ///   - label: Accessibility label.
        ///   - isFontScalingEnabled: Flag that provides font dynamic type by setting 
        ///   `adjustsFontForContentSizeCategory` for component that supports it.
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
