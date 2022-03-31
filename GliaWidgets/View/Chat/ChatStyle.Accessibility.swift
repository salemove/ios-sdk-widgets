extension ChatStyle {
    /// Accessibility properties for ChatStyle.
    public struct Accessibility: Equatable {
        /// Localized 'operator' to be used in case if operator name is not provided for accessibility label.
        public var `operator`: String
        /// Localized visitor name or reference to be used for accessibility label.
        public var visitor: String

        ///
        /// - Parameters:
        ///   - operator: Localized 'operator' to be used in case if operator name is not provided for accessibility label.
        ///   - visitor: Localized visitor name or reference to be used for accessibility label.
        public init(
            operator: String,
            visitor: String
        ) {
            self.operator = `operator`
            self.visitor = visitor
        }

        /// Accessibility is not supported intentionally.
        public static let unsupported = Self(
            operator: "",
            visitor: ""
        )
    }
}
