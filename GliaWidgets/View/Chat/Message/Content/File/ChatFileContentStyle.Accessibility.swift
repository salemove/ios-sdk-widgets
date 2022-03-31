extension ChatFileContentStyle {
    /// Accessibility properties for ChatFileContentStyle.
    public struct Accessibility: Equatable {
        /// Accessibility label for content view.
        public var contentAccessibilityLabel: String
        /// Accessibility label placeholder.
        public var youAccessibilityPlaceholder: String

        ///
        /// - Parameters:
        ///   - contentAccessibilityLabel: Accessibility label for content view.
        ///   - youAccessibilityPlaceholder: Accessibility label placeholder.
        public init(
            contentAccessibilityLabel: String,
            youAccessibilityPlaceholder: String
        ) {
            self.contentAccessibilityLabel = contentAccessibilityLabel
            self.youAccessibilityPlaceholder = youAccessibilityPlaceholder
        }

        /// Accessibility is not supported intentionally.
        public static let unsupported = Self(
            contentAccessibilityLabel: "",
            youAccessibilityPlaceholder: ""
        )
    }
}
