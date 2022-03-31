extension CallStyle {
    /// Accessibility properties for CallStyle.
    public struct Accessibility: Equatable {
        /// Accessibility hint for operator name label.
        public var operatorNameHint: String
        /// Accessibility hint for call duration label.
        public var durationHint: String
        /// Accessibility label for local (visitor) video.
        public var localVideoLabel: String
        /// Accessibility label for remote (operator) video.
        public var remoteVideoLabel: String

        ///
        /// - Parameters:
        ///   - operatorNameHint: Accessibility hint for operator name label.
        ///   - durationHint: Accessibility hint for call duration label.
        ///   - localVideoLabel: Accessibility label for local (visitor) video.
        ///   - remoteVideoLabel: Accessibility label for remote (operator) video.
        public init(
            operatorNameHint: String,
            durationHint: String,
            localVideoLabel: String,
            remoteVideoLabel: String
        ) {
            self.operatorNameHint = operatorNameHint
            self.durationHint = durationHint
            self.localVideoLabel = localVideoLabel
            self.remoteVideoLabel = remoteVideoLabel
        }

        /// Accessibility is not supported intentionally.
        public static let unsupported = Self(
            operatorNameHint: "",
            durationHint: "",
            localVideoLabel: "",
            remoteVideoLabel: ""
        )
    }
}
