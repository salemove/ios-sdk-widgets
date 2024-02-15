extension ConnectStatusStyle {
    /// Accessibility properties for ConnectStatusStyle.
    public struct Accessibility: Equatable {
        /// Accessibility hint for the first text label.
        public var firstTextHint: String

        /// Accessibility hint for the second text label.
        public var secondTextHint: String?

        /// Flag that provides font dynamic type by setting `adjustsFontForContentSizeCategory` 
        /// for component that supports it.
        public var isFontScalingEnabled: Bool

        /// - Parameters:
        ///   - firstTextHint: Accessibility hint for the first text label.
        ///   - secondTextHint: Accessibility hint for the second text label.
        ///   - isFontScalingEnabled: Flag that provides font dynamic type by setting 
        ///    `adjustsFontForContentSizeCategory` for component that supports it.
        ///
        public init(
            firstTextHint: String,
            secondTextHint: String?,
            isFontScalingEnabled: Bool
        ) {
            self.firstTextHint = firstTextHint
            self.secondTextHint = secondTextHint
            self.isFontScalingEnabled = isFontScalingEnabled
        }
    }
}

extension ConnectStatusStyle.Accessibility {
    /// Accessibility is not supported intentionally.
    public static let unsupported = Self(
        firstTextHint: "",
        secondTextHint: "",
        isFontScalingEnabled: false
    )
}
