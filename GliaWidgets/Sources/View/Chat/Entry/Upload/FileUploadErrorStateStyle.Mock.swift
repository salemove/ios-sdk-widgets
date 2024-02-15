import UIKit

#if DEBUG
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
