import UIKit

extension UIEdgeInsets {
    static func + (lhs: UIEdgeInsets, rhs: UIEdgeInsets) -> UIEdgeInsets {
        UIEdgeInsets(
            top: lhs.top + rhs.top,
            left: lhs.left + rhs.left,
            bottom: lhs.bottom + rhs.bottom,
            right: lhs.right + rhs.right
        )
    }

    static func - (lhs: UIEdgeInsets, rhs: UIEdgeInsets) -> UIEdgeInsets {
        UIEdgeInsets(
            top: lhs.top - rhs.top,
            left: lhs.left - rhs.left,
            bottom: lhs.bottom - rhs.bottom,
            right: lhs.right - rhs.right
        )
    }

    static func top(_ inset: CGFloat) -> UIEdgeInsets {
        UIEdgeInsets(top: inset, left: 0, bottom: 0, right: 0)
    }

    static func left(_ inset: CGFloat) -> UIEdgeInsets {
        UIEdgeInsets(top: 0, left: inset, bottom: 0, right: 0)
    }

    static func bottom(_ inset: CGFloat) -> UIEdgeInsets {
        UIEdgeInsets(top: 0, left: 0, bottom: inset, right: 0)
    }

    static func right(_ inset: CGFloat) -> UIEdgeInsets {
        UIEdgeInsets(top: 0, left: 0, bottom: 0, right: inset)
    }

    static func horizontal(_ inset: CGFloat) -> UIEdgeInsets {
        UIEdgeInsets(top: 0, left: inset, bottom: 0, right: inset)
    }

    static func vertical(_ inset: CGFloat) -> UIEdgeInsets {
        UIEdgeInsets(top: inset, left: 0, bottom: inset, right: 0)
    }

    static func uniform(_ inset: CGFloat) -> UIEdgeInsets {
        UIEdgeInsets(top: inset, left: inset, bottom: inset, right: inset)
    }
}
