import UIKit

/// Style of a single upload view in the uploads list view.
public class FileUploadStyle {
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

    /// Accessibility related properties.
    public var accessibility: Accessibility

    ///
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
    ///   - accessibility: Accessibility related properties.
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
        self.accessibility = accessibility
    }

    func apply(configuration: RemoteConfiguration.FileUploadBar?) {
        filePreview.apply(configuration: configuration?.filePreview)
        uploading.apply(configuration: configuration?.uploading)
        uploaded.apply(configuration: configuration?.uploaded)
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

        configuration?.removeButton?.value
            .map { UIColor(hex: $0) }
            .first
            .map { removeButtonColor = $0 }
    }
}

/// Style of an upload state.
public class FileUploadStateStyle {
    /// Text for the state.
    public var text: String

    /// Font of the state text.
    public var font: UIFont

    /// Color of the state text.
    public var textColor: UIColor

    /// Text style of the state text.
    public var textStyle: UIFont.TextStyle

    /// Font of the file info information text.
    public var infoFont: UIFont

    /// Color of the file information text.
    public var infoColor: UIColor

    /// Text style of the info text.
    public var infoTextStyle: UIFont.TextStyle

    ///
    /// - Parameters:
    ///   - text: Text for the state.
    ///   - font: Font of the state text.
    ///   - textColor: Color of the state text.
    ///   - textStyle: Text style of the state text.
    ///   - infoFont: Font of the file info information text.
    ///   - infoColor: Color of the file information text.
    ///   - infoTextStyle: Text style of the info text.
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

    func apply(configuration: RemoteConfiguration.FileState?) {
        configuration?.text?.foreground?.value
            .map { UIColor(hex: $0) }
            .first
            .map { textColor = $0 }

        UIFont.convertToFont(
            font: configuration?.text?.font,
            textStyle: textStyle
        ).map { font = $0 }

        configuration?.info?.foreground?.value
            .map { UIColor(hex: $0) }
            .first
            .map { infoColor = $0 }

        UIFont.convertToFont(
            font: configuration?.info?.font,
            textStyle: infoTextStyle
        ).map { infoFont = $0 }
    }
}

/// Style of an upload error state.
public class FileUploadErrorStateStyle {
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

    /// Information text to display when selected file is too big.
    public var infoFileTooBig: String

    /// Information text to display when selected file type is not supported.
    public var infoUnsupportedFileType: String

    /// Information text to display when selected file safety check failed.
    public var infoSafetyCheckFailed: String

    /// Information text to display on network related error.
    public var infoNetworkError: String

    /// Information text to display on generic error.
    public var infoGenericError: String

    ///
    /// - Parameters:
    ///   - text: Text for the state.
    ///   - font: Font of the state text.
    ///   - textColor: Color of the state text.
    ///   - textStyle: Text style of the state text.
    ///   - infoFont: Font of the information text.
    ///   - infoColor: Color of the information text.
    ///   - infoTextStyle: Text style of the information text.
    ///   - infoFileTooBig: Information text to display when selected file is too big.
    ///   - infoUnsupportedFileType: Information text to display when selected file type is not supported.
    ///   - infoSafetyCheckFailed: Information text to display when selected file safety check failed.
    ///   - infoNetworkError: Information text to display on network related error.
    ///   - infoGenericError: Information text to display on generic error.
    ///
    public init(
        text: String,
        font: UIFont,
        textColor: UIColor,
        textStyle: UIFont.TextStyle = .subheadline,
        infoFont: UIFont,
        infoColor: UIColor,
        infoTextStyle: UIFont.TextStyle = .caption1,
        infoFileTooBig: String,
        infoUnsupportedFileType: String,
        infoSafetyCheckFailed: String,
        infoNetworkError: String,
        infoGenericError: String
    ) {
        self.text = text
        self.font = font
        self.textColor = textColor
        self.textStyle = textStyle
        self.infoFont = infoFont
        self.infoColor = infoColor
        self.infoTextStyle = infoTextStyle
        self.infoFileTooBig = infoFileTooBig
        self.infoUnsupportedFileType = infoUnsupportedFileType
        self.infoSafetyCheckFailed = infoSafetyCheckFailed
        self.infoNetworkError = infoNetworkError
        self.infoGenericError = infoGenericError
    }

    func apply(configuration: RemoteConfiguration.FileState?) {
        configuration?.text?.foreground?.value
            .map { UIColor(hex: $0) }
            .first
            .map { textColor = $0 }

        UIFont.convertToFont(
            font: configuration?.text?.font,
            textStyle: textStyle
        ).map { font = $0 }

        configuration?.info?.foreground?.value
            .map { UIColor(hex: $0) }
            .first
            .map { infoColor = $0 }

        UIFont.convertToFont(
            font: configuration?.info?.font,
            textStyle: infoTextStyle
        ).map { infoFont = $0 }
    }
}

#if DEBUG
extension FileUploadStyle {
    static var mock: FileUploadStyle {
        FileUploadStyle(
            filePreview: .mock,
            uploading: .mock,
            uploaded: .mock,
            error: .mock,
            progressColor: .clear,
            errorProgressColor: .clear,
            progressBackgroundColor: .clear,
            removeButtonImage: UIImage(),
            removeButtonColor: .clear,
            accessibility: .unsupported
        )
    }
}

extension FileUploadStateStyle {
    static var mock: FileUploadStateStyle {
        FileUploadStateStyle(
            text: "",
            font: .systemFont(ofSize: 10),
            textColor: .clear,
            infoFont: .systemFont(ofSize: 10),
            infoColor: .clear
        )
    }
}

extension FileUploadErrorStateStyle {
    static var mock: FileUploadErrorStateStyle {
        FileUploadErrorStateStyle(
            text: "",
            font: .systemFont(ofSize: 10),
            textColor: .clear,
            infoFont: .systemFont(ofSize: 10),
            infoColor: .clear,
            infoFileTooBig: "",
            infoUnsupportedFileType: "",
            infoSafetyCheckFailed: "",
            infoNetworkError: "",
            infoGenericError: ""
        )
    }
}
#endif
