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

    func apply(
        configuration: RemoteConfiguration.FileMessage?,
        assetsBuilder: RemoteConfiguration.AssetsBuilder
    ) {
        filePreview.apply(
            configuration: configuration?.preview,
            assetsBuilder: assetsBuilder
        )
        download.apply(
            configuration: configuration?.download,
            assetsBuilder: assetsBuilder
        )
        downloading.apply(
            configuration: configuration?.downloading,
            assetsBuilder: assetsBuilder
        )
        open.apply(
            configuration: configuration?.downloaded,
            assetsBuilder: assetsBuilder
        )
        error.apply(
            configuration: configuration?.error,
            assetsBuilder: assetsBuilder
        )

        configuration?.progress?.value
            .map { UIColor(hex: $0) }
            .first
            .unwrap { progressColor = $0 }

        configuration?.errorProgress?.value
            .map { UIColor(hex: $0) }
            .first
            .unwrap { errorProgressColor = $0 }

        configuration?.progressBackground?.value
            .map { UIColor(hex: $0) }
            .first
            .unwrap { progressBackgroundColor = $0 }

        configuration?.border?.value
            .map { UIColor(hex: $0) }
            .first
            .unwrap { borderColor = $0 }

        configuration?.background?.value
            .map { UIColor(hex: $0) }
            .first
            .unwrap { backgroundColor = $0 }
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

    /// Text style of the state text.
    public var textStyle: UIFont.TextStyle

    /// Font of the file information text.
    public var infoFont: UIFont

    /// Color of the file information text.
    public var infoColor: UIColor

    /// Text style of the information text.
    public var infoTextStyle: UIFont.TextStyle

    ///
    /// - Parameters:
    ///   - text: Text for the state.
    ///   - font: Font of the state text.
    ///   - textColor: Color of the state text.
    ///   - textStyle: Text style of the state text.
    ///   - infoFont: Font of the file information text.
    ///   - infoColor: Color of the file information text.
    ///   - infoTextStyle: Text style of the information text.
    ///
    public init(
        text: String,
        font: UIFont,
        textColor: UIColor,
        textStyle: UIFont.TextStyle = .subheadline,
        infoFont: UIFont,
        infoColor: UIColor,
        infoTextStyle: UIFont.TextStyle = .caption1
    ) {
        self.text = text
        self.font = font
        self.textColor = textColor
        self.textStyle = textStyle
        self.infoFont = infoFont
        self.infoColor = infoColor
        self.infoTextStyle = infoTextStyle
    }

    func apply(
        configuration: RemoteConfiguration.FileState?,
        assetsBuilder: RemoteConfiguration.AssetsBuilder
    ) {
        UIFont.convertToFont(
            uiFont: assetsBuilder.fontBuilder(configuration?.text?.font),
            textStyle: textStyle
        ).unwrap { font = $0 }

        configuration?.text?.foreground?.value
            .map { UIColor(hex: $0) }
            .first
            .unwrap { textColor = $0 }

        UIFont.convertToFont(
            uiFont: assetsBuilder.fontBuilder(configuration?.info?.font),
            textStyle: infoTextStyle
        ).unwrap { infoFont = $0 }

        configuration?.info?.foreground?.value
            .map { UIColor(hex: $0) }
            .first
            .unwrap { infoColor = $0 }
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

    /// Text style of the state text.
    public var textStyle: UIFont.TextStyle

    /// Font of the information text.
    public var infoFont: UIFont

    /// Color of the information text.
    public var infoColor: UIColor

    /// Text style of the information text.
    public var infoTextStyle: UIFont.TextStyle

    /// The text between the state text and retry text.
    public var separatorText: String

    /// Font of the separator text.
    public var separatorFont: UIFont

    /// Color of the separator text.
    public var separatorTextColor: UIColor

    /// Text style of the separator text.
    public var separatorTextStyle: UIFont.TextStyle

    /// Retry text.
    public var retryText: String

    /// Font of the retry text.
    public var retryFont: UIFont

    /// Color of the retry text.
    public var retryTextColor: UIColor

    /// Text style of the retry text.
    public var retryTextStyle: UIFont.TextStyle

    ///
    /// - Parameters:
    ///   - text: Text for the state.
    ///   - font: Font of the state text.
    ///   - textColor: Color of the state text.
    ///   - textStyle: Text style of the state text.
    ///   - infoFont: Font of the information text.
    ///   - infoColor: Color of the information text.
    ///   - infoTextStyle: Text style of the information text.
    ///   - separatorText: The text between the state text and retry text.
    ///   - separatorFont: Font of the separator text.
    ///   - separatorTextColor: Color of the separator text.
    ///   - separatorTextStyle: Text style of the separator text.
    ///   - retryText: Retry text.
    ///   - retryFont: Font of the retry text.
    ///   - retryTextColor: Color of the retry text.
    ///   - retryTextStyle: Text style of the retry text.
    ///
    public init(
        text: String,
        font: UIFont,
        textColor: UIColor,
        textStyle: UIFont.TextStyle = .subheadline,
        infoFont: UIFont,
        infoColor: UIColor,
        infoTextStyle: UIFont.TextStyle = .caption1,
        separatorText: String,
        separatorFont: UIFont,
        separatorTextColor: UIColor,
        separatorTextStyle: UIFont.TextStyle = .footnote,
        retryText: String,
        retryFont: UIFont,
        retryTextColor: UIColor,
        retryTextStyle: UIFont.TextStyle = .subheadline
    ) {
        self.text = text
        self.font = font
        self.textColor = textColor
        self.textStyle = textStyle
        self.infoFont = infoFont
        self.infoColor = infoColor
        self.infoTextStyle = infoTextStyle
        self.separatorText = separatorText
        self.separatorFont = separatorFont
        self.separatorTextColor = separatorTextColor
        self.separatorTextStyle = separatorTextStyle
        self.retryText = retryText
        self.retryFont = retryFont
        self.retryTextColor = retryTextColor
        self.retryTextStyle = retryTextStyle
    }

    func apply(
        configuration: RemoteConfiguration.FileErrorState?,
        assetsBuilder: RemoteConfiguration.AssetsBuilder
    ) {
        UIFont.convertToFont(
            uiFont: assetsBuilder.fontBuilder(configuration?.text?.font),
            textStyle: textStyle
        ).unwrap { font = $0 }

        configuration?.text?.foreground?.value
            .map { UIColor(hex: $0) }
            .first
            .unwrap { textColor = $0 }

        UIFont.convertToFont(
            uiFont: assetsBuilder.fontBuilder(configuration?.info?.font),
            textStyle: infoTextStyle
        ).unwrap { infoFont = $0 }

        configuration?.info?.foreground?.value
            .map { UIColor(hex: $0) }
            .first
            .unwrap { infoColor = $0 }

        UIFont.convertToFont(
            uiFont: assetsBuilder.fontBuilder(configuration?.separator?.font),
            textStyle: separatorTextStyle
        ).unwrap { separatorFont = $0 }

        configuration?.separator?.foreground?.value
            .map { UIColor(hex: $0) }
            .first
            .unwrap { separatorTextColor = $0 }

        UIFont.convertToFont(
            uiFont: assetsBuilder.fontBuilder(configuration?.retry?.font),
            textStyle: retryTextStyle
        ).unwrap { retryFont = $0 }

        configuration?.retry?.foreground?.value
            .map { UIColor(hex: $0) }
            .first
            .unwrap { retryTextColor = $0 }
    }
}
