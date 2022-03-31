extension FileUploadStyle {
    /// Accessibility properties for FileUploadStyle.
    public struct Accessibility: Equatable {
        /// Accessibility label of the remove button.
        public var removeButtonAccessibilityLabel: String

        /// Upload progress format string, represented as '{uploadPercentValue}%' depending on localized string.
        public var progressPercentValue: String

        /// Accessibility value represented as file name followed be upload progress using '{uploadedFileName}, {uploadPercentValue}%' pattern from localized string.
        public var fileNameWithProgressValue: String

        ///
        /// - Parameters:
        ///   - removeButtonAccessibilityLabel: Accessibility label of the remove button.
        ///   - progressPercentValue: Upload progress format string, represented as '{uploadPercentValue}%' depending on localized string.
        ///   - fileNameWithProgressValue: Accessibility value represented as file name followed be upload progress using '{uploadedFileName}, {uploadPercentValue}%' pattern from localized string.
        public init(
            removeButtonAccessibilityLabel: String,
            progressPercentValue: String,
            fileNameWithProgressValue: String
        ) {
            self.removeButtonAccessibilityLabel = removeButtonAccessibilityLabel
            self.progressPercentValue = progressPercentValue
            self.fileNameWithProgressValue = fileNameWithProgressValue
        }

        /// Accessibility is not supported intentionally.
        public static let unsupported = Self(
            removeButtonAccessibilityLabel: "",
            progressPercentValue: "",
            fileNameWithProgressValue: ""
        )
    }
}
