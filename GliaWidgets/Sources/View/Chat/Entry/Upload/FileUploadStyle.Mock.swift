import UIKit

#if DEBUG
extension FileUploadStyle.EnabledDisabledState {
    static let mock = Self(
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

extension FileUploadStyle {
    static var mock: Self {
        Self(
            enabled: .mock,
            disabled: .mock
        )
    }
}
#endif
