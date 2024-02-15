import Foundation

extension FilePreviewStyle {
    public static func == (lhs: FilePreviewStyle, rhs: FilePreviewStyle) -> Bool {
        lhs.fileFont == rhs.fileFont &&
        lhs.fileColor == rhs.fileColor &&
        lhs.fileTextStyle == rhs.fileTextStyle &&
        lhs.errorIcon == rhs.errorIcon &&
        lhs.errorIconColor == rhs.errorIconColor &&
        lhs.backgroundColor == rhs.backgroundColor &&
        lhs.errorBackgroundColor == rhs.errorBackgroundColor &&
        lhs.cornerRadius == rhs.cornerRadius &&
        lhs.accessibility == rhs.accessibility
    }
}
