extension UnreadMessageIndicatorStyle {
    /// Accessibility properties for UnreadMessageIndicatorStyle.
    public struct Accessibility: Equatable {
        /// Accessibility label.
        public var label: String

        /// - Parameters:
        ///   - label: Accessibility label
        ///
        public init(label: String) {
            self.label = label
        }
    }
}

extension UnreadMessageIndicatorStyle.Accessibility {
    /// Accessibility is not supported intentionally.
    public static let unsupported = Self(label: "")
}
