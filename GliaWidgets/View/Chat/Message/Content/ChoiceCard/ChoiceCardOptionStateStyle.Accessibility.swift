extension ChoiceCardOptionStateStyle {
    /// Accessibility properties for ChoiceCardOptionStateStyle.
    public struct Accessibility: Equatable {
        /// Accessibility value.
        public var value: String

        ///
        /// - Parameter value: Accessibility value.
        public init(value: String) {
            self.value = value
        }

        /// Accessibility is not supported intentionally.
        public static let unsupported = Self(value: "")
    }
}
