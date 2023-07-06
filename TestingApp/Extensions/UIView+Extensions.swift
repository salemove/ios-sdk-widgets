import UIKit

extension UIView {
    /// Checks if current view is firstResponder, if not check the same
    /// for every subview. This is handy when we need to know if keyboard
    /// is presented at the moment by the view or its subviews.
    /// - Returns: `true` if view or subviews has `isFirstResponder` set to `true`.
    func isKeyboardPresented() -> Bool {
        Self.hasResponder(self)
    }

    private static func hasResponder(_ view: UIView) -> Bool {
        if view.isFirstResponder {
            return true
        }
        for subview in view.subviews {
            if hasResponder(subview) {
                return true
            }
        }

        return false
    }

    /// Search for superview in view hierarchy using predicate closure.
    /// This is useful when we need to get access from cell to table view for
    /// example.
    /// - Parameter predicate: Closure that receives view, as parameter,
    /// to be inspected by the predicate. `superview` traversal is stopped when there's no `superview`
    /// or if `superview` matches predicate.
    /// - Returns: View that matches predicate or nil otherwise.
    func superview(by predicate: (UIView) -> Bool) -> UIView? {
        if let superview {
            if predicate(superview) {
                return superview
            } else {
                return superview.superview(by: predicate)
            }
        }

        return nil
    }
}
