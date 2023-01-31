#if DEBUG
import UIKit

extension OnHoldOverlayStyle {
    static func mock(
        image: UIImage = .init(),
        imageColor: ColorType = .fill(color: .red),
        imageSize: CGSize = .zero
    ) -> OnHoldOverlayStyle {
        .init(
            image: image,
            imageColor: imageColor,
            imageSize: imageSize
        )
    }
}
#endif
