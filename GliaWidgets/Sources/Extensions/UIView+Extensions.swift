import UIKit

private let reusableIdentifier = "theme.reusableIdentifier.background"

extension UIView {
    /// Adds a CAGradientLayer to an existing view, taking colors and corner radius
    /// as parameters. If the view's base layer is already a gradient, it won't redraw it.
    @discardableResult func makeGradientBackground(colors: [CGColor], cornerRadius: CGFloat? = nil) -> CAGradientLayer {
        let l: CAGradientLayer

        if let index = layer.sublayers?.firstIndex(where: { $0.name == reusableIdentifier }),
           let existedLayer = layer.sublayers?[index] as? CAGradientLayer {
            l = existedLayer
        } else {
            l = CAGradientLayer()
        }
        l.name = reusableIdentifier
        l.frame = self.bounds
        l.colors = colors
        l.startPoint = CGPoint(x: 0, y: 0.5)
        l.endPoint = CGPoint(x: 1, y: 0.5)
        l.cornerRadius = cornerRadius ?? 0.0
        if l.superlayer == nil {
            layer.insertSublayer(l, at: 0)
        }

        return l
    }
}
