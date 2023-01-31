public extension Theme.SurveyStyle.OptionButton {
    /// Accessibility properties for OptionButton.
    struct Accessibility {
        /// Flag that provides font dynamic type by setting `adjustsFontForContentSizeCategory` for component that supports it.
        public var isFontScalingEnabled: Bool

        ///
        /// - Parameter connect: Styles for different engagement connection states.
        public init(isFontScalingEnabled: Bool) {
            self.isFontScalingEnabled = isFontScalingEnabled
        }
    }
}
