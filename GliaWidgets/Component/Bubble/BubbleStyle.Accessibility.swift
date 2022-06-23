extension BubbleStyle {
    /// Accessibility properties for BubbleStyle.
    public struct Accessibility: Equatable {
        /// Accessibility label for BubbleView.
        public var label: String
        /// Accessibility hint for BubbleView.
        public var hint: String

        ///
        /// - Parameters:
        ///   - label: Accessibility label for BubbleView.
        ///   - hint: Accessibility hint for BubbleView.
        public init(label: String, hint: String) {
            self.label = label
            self.hint = hint
        }

        /// Accessibility is not supported intentionally.
        public static let unsupported = Self(
            label: "",
            hint: ""
        )
    }
}
