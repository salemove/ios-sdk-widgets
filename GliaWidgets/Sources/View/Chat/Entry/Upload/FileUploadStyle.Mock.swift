import UIKit

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
#endif
