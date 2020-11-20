import UIKit

struct BackButtonProperties: ButtonProperties {
    let image: UIImage? = Asset.back.image
    let touchAreaInsets: TouchAreaInsets? = (dx: -10.0, dy: -10.0)
}
