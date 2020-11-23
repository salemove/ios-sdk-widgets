import UIKit

struct CloseButtonProperties: ButtonProperties {
    let image: UIImage? = Asset.close.image
    let width: CGFloat? = 30
    let height: CGFloat? = 30
    let touchAreaInsets: TouchAreaInsets? = (dx: -10.0, dy: -10.0)
}
