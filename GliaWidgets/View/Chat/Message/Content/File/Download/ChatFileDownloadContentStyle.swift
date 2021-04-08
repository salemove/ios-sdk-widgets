import UIKit

/// Style of a chat attachment's download view.
public class ChatFileDownloadStyle: ChatFileContentStyle {
    /// Style of the file's image.
    public var fileImage: FileImageStyle

    /// Style of the download state.
    public var download: ChatFileDownloadStateStyle

    /// Style of the downloading state.
    public var downloading: ChatFileDownloadStateStyle

    /// Style of the  state when file is downloaded and can be opened.
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

    ///
    /// - Parameters:
    ///   - fileImage: Style of the file's image.
    ///   - download: Style of the download state.
    ///   - downloading: Style of the downloading state.
    ///   - open: Style of the  state when file is downloaded and can be opened.
    ///   - error: Style of the error state.
    ///   - progressColor: Foreground color of the upload progress bar.
    ///   - errorProgressColor: Foreground color of the upload progress bar in error state.
    ///   - progressBackgroundColor: Background color of the upload progress bar.
    ///   - backgroundColor: Background color of the view.
    ///   - borderColor: Border color of the view.
    ///
    public init(fileImage: FileImageStyle,
                download: ChatFileDownloadStateStyle,
                downloading: ChatFileDownloadStateStyle,
                open: ChatFileDownloadStateStyle,
                error: ChatFileDownloadErrorStateStyle,
                progressColor: UIColor,
                errorProgressColor: UIColor,
                progressBackgroundColor: UIColor,
                backgroundColor: UIColor,
                borderColor: UIColor) {
        self.fileImage = fileImage
        self.download = download
        self.downloading = downloading
        self.open = open
        self.error = error
        self.progressColor = progressColor
        self.errorProgressColor = errorProgressColor
        self.progressBackgroundColor = progressBackgroundColor
        self.borderColor = borderColor
        super.init(backgroundColor: backgroundColor)
    }
}

/// Style of an download state.
public class ChatFileDownloadStateStyle {
    /// Text for the state.
    public var text: String

    /// Font of the state text.
    public var font: UIFont

    /// Color of the state text.
    public var textColor: UIColor

    /// Font of the file info information text.
    public var infoFont: UIFont

    /// Color of the file information text.
    public var infoColor: UIColor

    ///
    /// - Parameters:
    ///   - text: Text for the state.
    ///   - font: Font of the state text.
    ///   - textColor: Color of the state text.
    ///   - infoFont: Font of the file info information text.
    ///   - infoColor: Color of the file information text.
    ///
    public init(text: String,
                font: UIFont,
                textColor: UIColor,
                infoFont: UIFont,
                infoColor: UIColor) {
        self.text = text
        self.font = font
        self.textColor = textColor
        self.infoFont = infoFont
        self.infoColor = infoColor
    }
}

/// Style of an download error state.
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

    /// The text between the state text and rety text.
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
    ///   - separatorText: The text between the state text and rety text.
    ///   - separatorFont: Font of the separator text.
    ///   - separatorTextColor: Color of the separator text.
    ///   - retryText: Retry text.
    ///   - retryFont: Font of the retry text.
    ///   - retryTextColor: Color of the retry text.
    ///
    public init(text: String,
                font: UIFont,
                textColor: UIColor,
                infoFont: UIFont,
                infoColor: UIColor,
                separatorText: String,
                separatorFont: UIFont,
                separatorTextColor: UIColor,
                retryText: String,
                retryFont: UIFont,
                retryTextColor: UIColor) {
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
}
