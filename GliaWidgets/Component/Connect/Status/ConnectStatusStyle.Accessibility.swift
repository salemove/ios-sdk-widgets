extension ConnectStatusStyle {
    /// Accessibility properties for ConnectStatusStyle.
    public struct Accessibility: Equatable {
        /// Accessibility hint for the first text label.
        public var firstTextHint: String
        /// Accessibility hint for the second text label.
        public var secondTextHint: String

        ///
        /// - Parameters:
        ///   - firstTextHint: Accessibility hint for the first text label.
        ///   - secondTextHint: Accessibility hint for the second text label.
        public init(
            firstTextHint: String,
            secondTextHint: String
        ) {
            self.firstTextHint = firstTextHint
            self.secondTextHint = secondTextHint
        }

        /// Accessibility is not supported intentionally.
        public static let unsupported = Self(
            firstTextHint: "",
            secondTextHint: ""
        )
    }
}
