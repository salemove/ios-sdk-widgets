extension HeaderButtonStyle {
    /// Accessibility properties of HeaderButtonStyle.
    public struct Accessibility: Equatable {
        /// Accessiblity label.
        public var label: String
        /// Accessibility hint.
        public var hint: String

        /// - Parameters:
        ///   - label: Accessiblity label.
        ///   - hint: Accessibility hint.
        ///
        public init(
            label: String,
            hint: String
        ) {
            self.label = label
            self.hint = hint
        }
    }
}

extension HeaderButtonStyle.Accessibility {
    /// Accessibility is not supported intentionally.
    public static let unsupported = Self(
        label: "",
        hint: ""
    )
}
