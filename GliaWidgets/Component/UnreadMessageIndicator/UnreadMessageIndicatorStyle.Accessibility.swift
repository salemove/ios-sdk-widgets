extension UnreadMessageIndicatorStyle {
    /// Accessibility properties for UnreadMessageIndicatorStyle.
    public struct Accessibility: Equatable {
        /// Accessibility label.
        public var label: String

        ///
        /// - Parameter label: Accessibility label.
        public init(label: String) {
            self.label = label
        }

        /// Accessibility is not supported intentionally.
        public static let unsupported = Self(label: "")
    }
}
