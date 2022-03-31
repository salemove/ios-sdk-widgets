extension ChatMessageEntryStyle {
    /// Accessibility properties for ChatMessageEntryStyle.
    public struct Accessibility: Equatable {
        /// Accessibility label for message text view.
        public var messageInputAccessibilityLabel: String

        ///
        /// - Parameter messageInputAccessibilityLabel: Accessibility label for message text view.
        public init(messageInputAccessibilityLabel: String) {
            self.messageInputAccessibilityLabel = messageInputAccessibilityLabel
        }

        /// Accessibility is not supported intentionally.
        public static let unsupported = Self(messageInputAccessibilityLabel: "")
    }
}
