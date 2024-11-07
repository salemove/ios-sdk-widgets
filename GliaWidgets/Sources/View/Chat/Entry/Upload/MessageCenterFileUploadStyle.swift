import UIKit

public struct MessageCenterFileUploadStyle: Equatable {
    /// Style of the enabled state for single upload view in the uploads list view for Message Center Welcome screen.
    public var enabled: EnabledDisabledState
    /// Style of the disabled state for single upload view in the uploads list view for Message Center Welcome screen.
    public var disabled: EnabledDisabledState

    /// - Parameters:
    ///   - enabled: Style of the enabled state for single upload view in the uploads list view for Message Center Welcome screen.
    ///   - disabled: Style of the disabled state for single upload view in the uploads list view for Message Center Welcome screen.
    public init(
        enabled: EnabledDisabledState,
        disabled: EnabledDisabledState
    ) {
        self.enabled = enabled
        self.disabled = disabled
    }
}

extension MessageCenterFileUploadStyle {
    /// Style of the enabled or disabled state for single upload view in the uploads list view for Message Center Welcome screen.
    public struct EnabledDisabledState: Equatable {
        /// Style of the file preview.
        public var filePreview: FilePreviewStyle

        /// Style of the uploading state.
        public var uploading: FileUploadStateStyle

        /// Style of the uploaded state.
        public var uploaded: FileUploadStateStyle

        /// Style of the error state.
        public var error: FileUploadErrorStateStyle

        /// Foreground color of the upload progress bar.
        public var progressColor: UIColor

        /// Foreground color of the upload progress bar in error state.
        public var errorProgressColor: UIColor

        /// Background color of the upload progress bar.
        public var progressBackgroundColor: UIColor

        /// Image of the remove button.
        public var removeButtonImage: UIImage

        /// Color of the remove button image.
        public var removeButtonColor: UIColor

        /// Background color of the upload item.
        public var backgroundColor: UIColor

        /// Accessibility related properties.
        public var accessibility: Accessibility

        /// - Parameters:
        ///   - filePreview: Style of the file preview.
        ///   - uploading: Style of the uploading state.
        ///   - uploaded: Style of the uploaded state.
        ///   - error: Style of the error state.
        ///   - progressColor: Foreground color of the upload progress bar.
        ///   - errorProgressColor: Foreground color of the upload progress bar in error state.
        ///   - progressBackgroundColor: Background color of the upload progress bar.
        ///   - removeButtonImage: Image of the remove button.
        ///   - removeButtonColor: Color of the remove button image.
        ///   - backgroundColor: Background color of the upload item.
        ///   - accessibility: Accessibility related properties.
        ///
        public init(
            filePreview: FilePreviewStyle,
            uploading: FileUploadStateStyle,
            uploaded: FileUploadStateStyle,
            error: FileUploadErrorStateStyle,
            progressColor: UIColor,
            errorProgressColor: UIColor,
            progressBackgroundColor: UIColor,
            removeButtonImage: UIImage,
            removeButtonColor: UIColor,
            backgroundColor: UIColor,
            accessibility: Accessibility = .unsupported
        ) {
            self.filePreview = filePreview
            self.uploading = uploading
            self.uploaded = uploaded
            self.error = error
            self.progressColor = progressColor
            self.errorProgressColor = errorProgressColor
            self.progressBackgroundColor = progressBackgroundColor
            self.removeButtonImage = removeButtonImage
            self.removeButtonColor = removeButtonColor
            self.backgroundColor = backgroundColor
            self.accessibility = accessibility
        }
    }
}
