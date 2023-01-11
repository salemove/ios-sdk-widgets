import UIKit

struct VisitorCodeCloseButtonProperties: ButtonProperties {
    let image: UIImage? = Asset.close.image
    let width: CGFloat? = 12
    let height: CGFloat? = 12
    let touchAreaInsets: TouchAreaInsets? = (dx: -10.0, dy: -10.0)
}
