#if DEBUG
import UIKit

extension OnHoldOverlayStyle {
    static func mock(
        image: UIImage = .init(),
        imageColor: UIColor = .red,
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
