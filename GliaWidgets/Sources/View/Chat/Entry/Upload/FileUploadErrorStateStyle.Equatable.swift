import Foundation

extension FileUploadErrorStateStyle {
    public static func == (lhs: FileUploadErrorStateStyle, rhs: FileUploadErrorStateStyle) -> Bool {
        lhs.text == rhs.text &&
        lhs.font == rhs.font &&
        lhs.textColor == rhs.textColor &&
        lhs.textStyle == rhs.textStyle &&
        lhs.infoFont == rhs.infoFont &&
        lhs.infoColor == rhs.infoColor &&
        lhs.infoTextStyle == rhs.infoTextStyle &&
        lhs.infoFileTooBig == rhs.infoFileTooBig &&
        lhs.infoUnsupportedFileType == rhs.infoUnsupportedFileType &&
        lhs.infoSafetyCheckFailed == rhs.infoSafetyCheckFailed &&
        lhs.infoNetworkError == rhs.infoNetworkError &&
        lhs.infoGenericError == rhs.infoGenericError
    }
}
