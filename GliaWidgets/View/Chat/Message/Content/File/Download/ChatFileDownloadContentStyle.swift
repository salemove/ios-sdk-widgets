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

    ///
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
    ///   - accessibility: Accessibility related roperties for ChatFileContentStyle.
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

    func apply(configuration: RemoteConfiguration.FileMessage?) {
        filePreview.apply(configuration: configuration?.preview)
        download.apply(configuration: configuration?.download)
        downloading.apply(configuration: configuration?.downloading)
        open.apply(configuration: configuration?.downloaded)
        error.apply(configuration: configuration?.error)

        configuration?.progress?.value
            .map { UIColor(hex: $0) }
            .first
            .map { progressColor = $0 }

        configuration?.errorProgress?.value
            .map { UIColor(hex: $0) }
            .first
            .map { errorProgressColor = $0 }

        configuration?.progressBackground?.value
            .map { UIColor(hex: $0) }
            .first
            .map { progressBackgroundColor = $0 }

        configuration?.border?.value
            .map { UIColor(hex: $0) }
            .first
            .map { borderColor = $0 }

        configuration?.background?.value
            .map { UIColor(hex: $0) }
            .first
            .map { backgroundColor = $0 }
    }
}

/// Style of a download state.
public class ChatFileDownloadStateStyle {
    /// Text for the state.
    public var text: String

    /// Font of the state text.
    public var font: UIFont

    /// Color of the state text.
    public var textColor: UIColor

    /// Font of the file information text.
    public var infoFont: UIFont

    /// Color of the file information text.
    public var infoColor: UIColor

    ///
    /// - Parameters:
    ///   - text: Text for the state.
    ///   - font: Font of the state text.
    ///   - textColor: Color of the state text.
    ///   - infoFont: Font of the file information text.
    ///   - infoColor: Color of the file information text.
    ///
    public init(
        text: String,
        font: UIFont,
        textColor: UIColor,
        infoFont: UIFont,
        infoColor: UIColor
    ) {
        self.text = text
        self.font = font
        self.textColor = textColor
        self.infoFont = infoFont
        self.infoColor = infoColor
    }

    func apply(configuration: RemoteConfiguration.FileState?) {
        configuration?.text?.font?.size
            .map { font = Font.regular($0) }

        configuration?.text?.foreground?.value
            .map { UIColor(hex: $0) }
            .first
            .map { textColor = $0 }

        configuration?.info?.font?.size
            .map { infoFont = Font.regular($0) }

        configuration?.info?.foreground?.value
            .map { UIColor(hex: $0) }
            .first
            .map { infoColor = $0 }
    }
}

/// Style of a download error state.
public class ChatFileDownloadErrorStateStyle {
    /// Text for the state.
    public var text: String

    /// Font of the state text.
    public var font: UIFont

    /// Color of the state text.
    public var textColor: UIColor

    /// Font of the information text.
    public var infoFont: UIFont

    /// Color of the information text.
    public var infoColor: UIColor

    /// The text between the state text and retry text.
    public var separatorText: String

    /// Font of the separator text.
    public var separatorFont: UIFont

    /// Color of the separator text.
    public var separatorTextColor: UIColor

    /// Retry text.
    public var retryText: String

    /// Font of the retry text.
    public var retryFont: UIFont

    /// Color of the retry text.
    public var retryTextColor: UIColor

    ///
    /// - Parameters:
    ///   - text: Text for the state.
    ///   - font: Font of the state text.
    ///   - textColor: Color of the state text.
    ///   - infoFont: Font of the information text.
    ///   - infoColor: Color of the information text.
    ///   - separatorText: The text between the state text and retry text.
    ///   - separatorFont: Font of the separator text.
    ///   - separatorTextColor: Color of the separator text.
    ///   - retryText: Retry text.
    ///   - retryFont: Font of the retry text.
    ///   - retryTextColor: Color of the retry text.
    ///
    public init(
        text: String,
        font: UIFont,
        textColor: UIColor,
        infoFont: UIFont,
        infoColor: UIColor,
        separatorText: String,
        separatorFont: UIFont,
        separatorTextColor: UIColor,
        retryText: String,
        retryFont: UIFont,
        retryTextColor: UIColor
    ) {
        self.text = text
        self.font = font
        self.textColor = textColor
        self.infoFont = infoFont
        self.infoColor = infoColor
        self.separatorText = separatorText
        self.separatorFont = separatorFont
        self.separatorTextColor = separatorTextColor
        self.retryText = retryText
        self.retryFont = retryFont
        self.retryTextColor = retryTextColor
    }

    func apply(configuration: RemoteConfiguration.FileErrorState?) {
        configuration?.text?.font?.size
            .map { font = Font.regular($0) }

        configuration?.text?.foreground?.value
            .map { UIColor(hex: $0) }
            .first
            .map { textColor = $0 }

        configuration?.info?.font?.size
            .map { infoFont = Font.regular($0) }

        configuration?.info?.foreground?.value
            .map { UIColor(hex: $0) }
            .first
            .map { infoColor = $0 }

        configuration?.separator?.font?.size
            .map { separatorFont = Font.regular($0) }

        configuration?.separator?.foreground?.value
            .map { UIColor(hex: $0) }
            .first
            .map { separatorTextColor = $0 }

        configuration?.retry?.font?.size
            .map { retryFont = Font.regular($0) }

        configuration?.retry?.foreground?.value
            .map { UIColor(hex: $0) }
            .first
            .map { retryTextColor = $0 }
    }
}
