import UIKit

protocol Makeable {}

/// Extends protocol with implementation for `UIView` the easiest way
///  to make customization for the view in one place with initialization.
extension Makeable where Self: UIView {
    /// Executes configuration closure and return self.
    func make(_ configuration: (Self) -> Void) -> Self {
        configuration(self)
        return self
    }

    /// Translates autoresizing mask into constraints and executes
    ///  empty configuration closure.
    func makeView() -> Self {
        makeView { _ in }
    }

    /// Translates autoresizing mask into constraints and executes
    ///  configuration closure.
    func makeView(_ configuration: (Self) -> Void) -> Self {
        translatesAutoresizingMaskIntoConstraints = false
        configuration(self)
        return self
    }
}

extension UIView: Makeable {}
