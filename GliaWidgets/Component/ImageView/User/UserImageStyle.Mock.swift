#if DEBUG
import UIKit

extension UserImageStyle {
    static func mock(
        placeholderImage: UIImage? = nil,
        placeholderColor: UIColor = .red,
        placeholderBackgroundColor: ColorType = .fill(color: .red),
        imageBackgroundColor: ColorType = .fill(color: .red),
        transferringImage: UIImage? = nil
    ) -> UserImageStyle {
        .init(
            placeholderImage: placeholderImage,
            placeholderColor: placeholderColor,
            placeholderBackgroundColor: placeholderBackgroundColor,
            imageBackgroundColor: imageBackgroundColor,
            transferringImage: transferringImage
        )
    }
}
#endif
