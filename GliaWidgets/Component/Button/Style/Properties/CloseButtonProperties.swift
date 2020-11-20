import UIKit

struct CloseButtonProperties: ButtonProperties {
    let image: UIImage? = Asset.close.image
    let touchAreaInsets: TouchAreaInsets? = (dx: -10.0, dy: -10.0)
}
