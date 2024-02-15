import Foundation

extension FileUploadStateStyle {
    public static func == (lhs: FileUploadStateStyle, rhs: FileUploadStateStyle) -> Bool {
        lhs.text == rhs.text &&
        lhs.font == rhs.font &&
        lhs.textColor == rhs.textColor &&
        lhs.textStyle == rhs.textStyle &&
        lhs.infoFont == rhs.infoFont &&
        lhs.infoColor == rhs.infoColor &&
        lhs.infoTextStyle == rhs.infoTextStyle
    }
}
