import UIKit

/// Style of a chat attachment download view.
public class ChatFileDownloadStyle: ChatFileContentStyle {
    /// Style of the file preview.
    public var filePreview: FilePreviewStyle

    /// Style of the download state.
    public var download: ChatFileDownloadStateStyle

    /// Style of the downloading state.
    public var downloading: ChatFileDownloadStateStyle

    /// Style of the state when file is downloaded and can be opened.
    public var open: ChatFileDownloadStateStyle

    /// Style of the error state.
    public var error: ChatFileDownloadErrorStateStyle

    /// Foreground color of the upload progress bar.
    public var progressColor: UIColor

    /// Foreground color of the upload progress bar in error state.
    public var errorProgressColor: UIColor

    /// Background color of the upload progress bar.
    public var progressBackgroundColor: UIColor

    /// Border color of the view.
    public var borderColor: UIColor

    /// Accessibility related properties for downloaded file states.
    public var stateAccessibility: StateAccessibility

    /// - Parameters:
    ///   - filePreview: Style of the file preview.
    ///   - download: Style of the download state.
    ///   - downloading: Style of the downloading state.
    ///   - open: Style of the state when file is downloaded and can be opened.
    ///   - error: Style of the error state.
    ///   - progressColor: Foreground color of the upload progress bar.
    ///   - errorProgressColor: Foreground color of the upload progress bar in error state.
    ///   - progressBackgroundColor: Background color of the upload progress bar.
    ///   - backgroundColor: Background color of the view.
    ///   - borderColor: Border color of the view.
    ///   - accessibility: Accessibility related properties for `ChatFileContentStyle`.
    ///   - downloadAccessibility: Accessibility related properties for downloaded file.
    ///
    public init(
        filePreview: FilePreviewStyle,
        download: ChatFileDownloadStateStyle,
        downloading: ChatFileDownloadStateStyle,
        open: ChatFileDownloadStateStyle,
        error: ChatFileDownloadErrorStateStyle,
        progressColor: UIColor,
        errorProgressColor: UIColor,
        progressBackgroundColor: UIColor,
        backgroundColor: UIColor,
        borderColor: UIColor,
        accessibility: Accessibility = .unsupported,
        downloadAccessibility: StateAccessibility = .unsupported
    ) {
        self.filePreview = filePreview
        self.download = download
        self.downloading = downloading
        self.open = open
        self.error = error
        self.progressColor = progressColor
        self.errorProgressColor = errorProgressColor
        self.progressBackgroundColor = progressBackgroundColor
        self.borderColor = borderColor
        self.stateAccessibility = downloadAccessibility
        super.init(
            backgroundColor: backgroundColor,
            accessibility: accessibility
        )
    }
}
