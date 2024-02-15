extension VisitorCodeStyle {
    /// Accessibility properties for AlertStyle.
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

extension VisitorCodeStyle.Accessibility {
    /// Accessibility is not supported intentionally.
    public static let unsupported = Self(isFontScalingEnabled: false)
}
