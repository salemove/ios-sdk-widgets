import UIKit

#if DEBUG
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
#endif
