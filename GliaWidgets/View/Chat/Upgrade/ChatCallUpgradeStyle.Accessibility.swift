extension ChatCallUpgradeStyle {
    /// Accessibility properties for ChatCallUpgradeStyle.
    public struct Accessibility {
        /// Accessibility hint for text reperesenting time.
        public var durationTextHint: String
        /// Flag that provides font dynamic type by setting `adjustsFontForContentSizeCategory` for component that supports it.
        public var isFontScalingEnabled: Bool

        ///
        /// - Parameters:
        ///   - durationTextHint: Accessibility hint for text reperesenting time.
        ///   - isFontScalingEnabled: Flag that provides font dynamic type by setting `adjustsFontForContentSizeCategory` for component that supports it.
        public init(
            durationTextHint: String,
            isFontScalingEnabled: Bool
        ) {
            self.durationTextHint = durationTextHint
            self.isFontScalingEnabled = isFontScalingEnabled
        }

        /// Accessibility is not supported intentionally.
        public static let unsupported = Self(
            durationTextHint: "",
            isFontScalingEnabled: false
        )
    }
}
