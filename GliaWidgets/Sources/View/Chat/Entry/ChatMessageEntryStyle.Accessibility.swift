extension ChatMessageEntryStyle {
    /// Accessibility properties for ChatMessageEntryStyle.
    public struct Accessibility: Equatable {
        /// Accessibility label for message text view.
        public var messageInputAccessibilityLabel: String
        /// Flag that provides font dynamic type by setting `adjustsFontForContentSizeCategory` for component that supports it.
        public var isFontScalingEnabled: Bool

        ///
        /// - Parameters:
        ///   - messageInputAccessibilityLabel: Accessibility label for message text view.
        ///   - isFontScalingEnabled: Flag that provides font dynamic type by setting `adjustsFontForContentSizeCategory` for component that supports it.
        public init(
            messageInputAccessibilityLabel: String,
            isFontScalingEnabled: Bool
        ) {
            self.messageInputAccessibilityLabel = messageInputAccessibilityLabel
            self.isFontScalingEnabled = isFontScalingEnabled
        }

        /// Accessibility is not supported intentionally.
        public static let unsupported = Self(
            messageInputAccessibilityLabel: "",
            isFontScalingEnabled: false
        )
    }
}
