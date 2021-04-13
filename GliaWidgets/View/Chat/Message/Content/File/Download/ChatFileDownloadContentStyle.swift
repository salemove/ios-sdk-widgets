import UIKit

public class ChatFileDownloadStyle: ChatFileContentStyle {
    public var fileImage: FileImageStyle
    public var download: ChatFileDownloadStateStyle
    public var downloading: ChatFileDownloadStateStyle
    public var open: ChatFileDownloadStateStyle
    public var error: ChatFileDownloadErrorStateStyle
    public var progressColor: UIColor
    public var errorProgressColor: UIColor
    public var progressBackgroundColor: UIColor
    public var borderColor: UIColor

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

public class ChatFileDownloadStateStyle {
    public var text: String
    public var font: UIFont
    public var textColor: UIColor
    public var infoFont: UIFont
    public var infoColor: UIColor

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

public class ChatFileDownloadErrorStateStyle {
    public var text: String
    public var font: UIFont
    public var textColor: UIColor
    public var infoFont: UIFont
    public var infoColor: UIColor
    public var separatorText: String
    public var separatorFont: UIFont
    public var separatorTextColor: UIColor
    public var retryText: String
    public var retryFont: UIFont
    public var retryTextColor: UIColor

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
