extension ChatCallUpgradeStyle {
    /// Accessibility properties for ChatCallUpgradeStyle.
    public struct Accessibility {
        /// Accessibility hint for text reperesenting time.
        public var durationTextHint: String

        ///
        /// - Parameter timeTextHint: Accessibility hint for text reperesenting time.
        public init(durationTextHint: String) {
            self.durationTextHint = durationTextHint
        }

        /// Accessibility is not supported intentionally.
        public static let unsupported = Self(durationTextHint: "")
    }
}
