extension ChatFileContentStyle {
    /// Accessibility properties for ChatFileContentStyle.
    public struct Accessibility: Equatable {
        /// Accessibility label for content view.
        public var contentAccessibilityLabel: String
        /// Accessibility label placeholder.
        public var youAccessibilityPlaceholder: String
        /// Flag that provides font dynamic type by setting `adjustsFontForContentSizeCategory` for component that supports it.
        public var isFontScalingEnabled: Bool

        ///
        /// - Parameters:
        ///   - contentAccessibilityLabel: Accessibility label for content view.
        ///   - youAccessibilityPlaceholder: Accessibility label placeholder.
        ///   - isFontScalingEnabled: Flag that provides font dynamic type by setting `adjustsFontForContentSizeCategory` for component that supports it.
        public init(
            contentAccessibilityLabel: String,
            youAccessibilityPlaceholder: String,
            isFontScalingEnabled: Bool
        ) {
            self.contentAccessibilityLabel = contentAccessibilityLabel
            self.youAccessibilityPlaceholder = youAccessibilityPlaceholder
            self.isFontScalingEnabled = isFontScalingEnabled
        }

        /// Accessibility is not supported intentionally.
        public static let unsupported = Self(
            contentAccessibilityLabel: "",
            youAccessibilityPlaceholder: "",
            isFontScalingEnabled: false
        )
    }
}
