extension ChoiceCardStyle {
    /// Accessibility properties for ChoiceCardStyle.
    public struct Accessibility: Equatable {
        /// Accessibility label for image.
        public var imageLabel: String

        ///
        /// - Parameter imageLabel: Accessibility label for image.
        public init(imageLabel: String) {
            self.imageLabel = imageLabel
        }

        /// Accessibility is not supported intentionally.
        public static let unsupported = Self(imageLabel: "")
    }
}
