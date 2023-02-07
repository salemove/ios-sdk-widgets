extension FileUploadStyle {
    /// Accessibility properties for FileUploadStyle.
    public struct Accessibility: Equatable {
        /// Accessibility label of the remove button.
        public var removeButtonAccessibilityLabel: String

        /// Upload progress format string, represented as '{uploadPercentValue}%' depending on localized string.
        public var progressPercentValue: String

        /// Accessibility value represented as file name followed be upload progress using '{uploadedFileName}, {uploadPercentValue}%' pattern from localized string.
        public var fileNameWithProgressValue: String

        /// Flag that provides font dynamic type by setting `adjustsFontForContentSizeCategory` for component that supports it.
        public var isFontScalingEnabled: Bool

        ///
        /// - Parameters:
        ///   - removeButtonAccessibilityLabel: Accessibility label of the remove button.
        ///   - progressPercentValue: Upload progress format string, represented as '{uploadPercentValue}%' depending on localized string.
        ///   - fileNameWithProgressValue: Accessibility value represented as file name followed be upload progress using '{uploadedFileName}, {uploadPercentValue}%' pattern from localized string.
        ///   - isFontScalingEnabled: Flag that provides font dynamic type by setting `adjustsFontForContentSizeCategory` for component that supports it.
        public init(
            removeButtonAccessibilityLabel: String,
            progressPercentValue: String,
            fileNameWithProgressValue: String,
            isFontScalingEnabled: Bool
        ) {
            self.removeButtonAccessibilityLabel = removeButtonAccessibilityLabel
            self.progressPercentValue = progressPercentValue
            self.fileNameWithProgressValue = fileNameWithProgressValue
            self.isFontScalingEnabled = isFontScalingEnabled
        }

        /// Accessibility is not supported intentionally.
        public static let unsupported = Self(
            removeButtonAccessibilityLabel: "",
            progressPercentValue: "",
            fileNameWithProgressValue: "",
            isFontScalingEnabled: false
        )
    }
}

extension MessageCenterFileUploadStyle {
    // TODO: MOB-1710
    public typealias Accessibility = FileUploadStyle.Accessibility
}
