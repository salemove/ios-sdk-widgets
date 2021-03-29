import UIKit

public class FileUploadStyle {
    public var fileImage: FileImageStyle
    public var uploading: FileUploadStateStyle
    public var uploaded: FileUploadStateStyle
    public var error: FileUploadErrorStateStyle
    public var progressColor: UIColor
    public var errorProgressColor: UIColor
    public var progressBackgroundColor: UIColor
    public var removeButtonImage: UIImage
    public var removeButtonColor: UIColor

    public init(fileImage: FileImageStyle,
                uploading: FileUploadStateStyle,
                uploaded: FileUploadStateStyle,
                error: FileUploadErrorStateStyle,
                progressColor: UIColor,
                errorProgressColor: UIColor,
                progressBackgroundColor: UIColor,
                removeButtonImage: UIImage,
                removeButtonColor: UIColor) {
        self.fileImage = fileImage
        self.uploading = uploading
        self.uploaded = uploaded
        self.error = error
        self.progressColor = progressColor
        self.errorProgressColor = errorProgressColor
        self.progressBackgroundColor = progressBackgroundColor
        self.removeButtonImage = removeButtonImage
        self.removeButtonColor = removeButtonColor
    }
}

public class FileUploadStateStyle {
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

public class FileUploadErrorStateStyle {
    public var text: String
    public var font: UIFont
    public var textColor: UIColor
    public var infoFont: UIFont
    public var infoColor: UIColor
    public var infoFileTooBig: String
    public var infoUnsupportedFileType: String
    public var infoSafetyCheckFailed: String
    public var infoNetworkError: String
    public var infoGenericError: String

    public init(text: String,
                font: UIFont,
                textColor: UIColor,
                infoFont: UIFont,
                infoColor: UIColor,
                infoFileTooBig: String,
                infoUnsupportedFileType: String,
                infoSafetyCheckFailed: String,
                infoNetworkError: String,
                infoGenericError: String) {
        self.text = text
        self.font = font
        self.textColor = textColor
        self.infoFont = infoFont
        self.infoColor = infoColor
        self.infoFileTooBig = infoFileTooBig
        self.infoUnsupportedFileType = infoUnsupportedFileType
        self.infoSafetyCheckFailed = infoSafetyCheckFailed
        self.infoNetworkError = infoNetworkError
        self.infoGenericError = infoGenericError
    }
}
