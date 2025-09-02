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

    @discardableResult
    func applyBackground(_ background: Theme.Layer?) -> UIView {
        guard let background else { return self }
        background.background.unwrap {
            switch $0 {
            case let .fill(color):
                backgroundColor = color
            case let .gradient(colors):
                makeGradientBackground(
                    colors: colors,
                    cornerRadius: background.cornerRadius
                )
            }
        }
        layer.cornerRadius = background.cornerRadius
        layer.borderColor = background.borderColor
        layer.borderWidth = background.borderWidth
        return self
    }

    /// Recursively searches for the first responder within the view's subview hierarchy.
    ///
    /// This method traverses the view's subviews to find the view that is currently
    /// the first responder. It's useful for locating the active text input field
    /// or other interactive element that has control.
    ///
    /// - Returns: The view that is the first responder, or `nil` if no descendant
    ///            view is the first responder.
    func firstResponderDescendant() -> UIView? {
        if isFirstResponder { return self }
        for s in subviews { if let r = s.firstResponderDescendant() { return r } }
        return nil
    }

    /// Search for superview in view hierarchy using predicate closure.
    /// This is useful when we need to get access from cell to table view for
    /// example.
    /// - Parameter predicate: Closure that receives view, as parameter,
    /// to be inspected by the predicate. `superview` traversal is stopped when there's no `superview`
    /// or if `superview` matches predicate.
    /// - Returns: View that matches predicate or nil otherwise.
    func superview(by predicate: (UIView) -> Bool) -> UIView? {
        guard let superview else { return nil }
        if predicate(superview) {
            return superview
        } else {
            return superview.superview(by: predicate)
        }
    }
}
