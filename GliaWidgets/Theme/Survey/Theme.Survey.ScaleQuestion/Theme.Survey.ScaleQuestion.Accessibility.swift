public extension Theme.SurveyStyle.ScaleQuestion {
    /// Accessibility properties for ScaleQuestion style.
    struct Accessibility {
        /// Flag that provides font dynamic type by setting `adjustsFontForContentSizeCategory` for component that supports it.
        public var isFontScalingEnabled: Bool

        ///
        /// - Parameter isFontScalingEnabled: Flag that provides font dynamic type by setting `adjustsFontForContentSizeCategory` for component that supports it.
        public init(isFontScalingEnabled: Bool) {
            self.isFontScalingEnabled = isFontScalingEnabled
        }
    }
}
