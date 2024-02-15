extension MessageButtonStyle {
    /// Accessibility properties of MessageButtonStyle.
    public struct Accessibility: Equatable {
        /// Accessibility label of the button.
        public var accessibilityLabel: String

        /// - Parameters:
        ///   - accessibilityLabel: Accessibility label of the button.
        ///
        public init(accessibilityLabel: String) {
            self.accessibilityLabel = accessibilityLabel
        }
    }
}

extension MessageButtonStyle.Accessibility {
    /// Accessibility is not supported intentionally.
    public static let unsupported = Self(accessibilityLabel: "")
}
