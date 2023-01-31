extension ConnectOperatorStyle {
    /// Accessibility properties for ConnectOperatorStyle.
    public struct Accessibility: Equatable {
        /// Accessibility label.
        public var label: String
        /// Accessibility hint.
        public var hint: String

        ///
        /// - Parameters:
        ///   - label: Accessibility label.
        ///   - hint: Accessibility hint.
        public init(
            label: String,
            hint: String
        ) {
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
