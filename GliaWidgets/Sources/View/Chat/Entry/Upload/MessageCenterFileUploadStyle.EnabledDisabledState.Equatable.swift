import Foundation

extension MessageCenterFileUploadStyle.EnabledDisabledState {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.filePreview == rhs.filePreview &&
        lhs.uploading == rhs.uploading &&
        lhs.uploaded == rhs.uploaded &&
        lhs.error == rhs.error &&
        lhs.progressColor == rhs.progressColor &&
        lhs.errorProgressColor == rhs.errorProgressColor &&
        lhs.progressBackgroundColor == rhs.progressBackgroundColor &&
        lhs.removeButtonImage == rhs.removeButtonImage &&
        lhs.removeButtonColor == rhs.removeButtonColor &&
        lhs.backgroundColor == rhs.backgroundColor &&
        lhs.accessibility == rhs.accessibility
    }
}
