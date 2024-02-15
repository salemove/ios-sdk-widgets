import UIKit

#if DEBUG
extension FilePreviewStyle {
    static var mock: FilePreviewStyle {
        FilePreviewStyle(
            fileFont: .systemFont(ofSize: 10),
            fileColor: .clear,
            errorIcon: UIImage(),
            errorIconColor: .clear,
            backgroundColor: .clear,
            errorBackgroundColor: .clear,
            accessibility: .unsupported
        )
    }
}
#endif
