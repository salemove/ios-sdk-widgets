import UIKit

/// Style of an upload error state.
public class FileUploadErrorStateStyle: Equatable {
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

    /// Information text to display when the selected file is too big.
    public var infoFileTooBig: String

    /// Information text to display when the type of the selected file is not supported.
    public var infoUnsupportedFileType: String

    /// Information text to display when the safety check for the selected file failed.
    public var infoSafetyCheckFailed: String

    /// Information text to display on network related error.
    public var infoNetworkError: String

    /// Information text to display on generic error.
    public var infoGenericError: String

    /// - Parameters:
    ///   - text: Text for the state.
    ///   - font: Font of the state text.
    ///   - textColor: Color of the state text.
    ///   - textStyle: Text style of the state text.
    ///   - infoFont: Font of the information text.
    ///   - infoColor: Color of the information text.
    ///   - infoTextStyle: Text style of the information text.
    ///   - infoFileTooBig: Information text to display when the selected file is too big.
    ///   - infoUnsupportedFileType: Information text to display when the type of the selected file is not supported.
    ///   - infoSafetyCheckFailed: Information text to display when the safety check for the selected file failed.
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
}
