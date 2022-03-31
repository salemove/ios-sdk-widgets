extension FileUploadStyle {
    /// Accessibility properties for FileUploadStyle.
    public struct Accessibility: Equatable {
        /// Accessibility label of the remove button.
        public var removeButtonAccessibilityLabel: String

        ///
        /// - Parameter removeButtonAccessibilityLabel: Accessibility label of the remove button.
        public init(removeButtonAccessibilityLabel: String) {
            self.removeButtonAccessibilityLabel = removeButtonAccessibilityLabel
        }

        /// Accessibility is not supported intentionally.
        public static let unsupported = Self(removeButtonAccessibilityLabel: "")
    }
}
