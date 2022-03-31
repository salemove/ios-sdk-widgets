extension MessageButtonStyle {
    /// Accessibility properties of MessageButtonStyle.
    public struct Accessibility: Equatable {
        /// Accessibility label of the button.
        public var accessibilityLabel: String

        ///
        /// - Parameter accessibilityLabel: Accessibility label of the button.
        public init(accessibilityLabel: String) {
            self.accessibilityLabel = accessibilityLabel
        }

        /// Accessibility is not supported intentionally.
        public static let unsupported = Self(accessibilityLabel: "")
    }
}
