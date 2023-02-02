import Foundation
import UIKit

extension Array where Element == NSLayoutConstraint {
    func constraints(with id: NSLayoutConstraint.Identifier) -> [NSLayoutConstraint] {
        filter { $0.identifier == id.rawValue }
    }
}

extension NSLayoutConstraint {
    /// Constraint identifier
    enum Identifier: String {
        case leading, top, trailing, bottom, width, height, greaterThanTop, lessThanBottom
    }

    /// Sets constraints priority
    func priority(_ newValue: UILayoutPriority) -> Self {
        priority = newValue
        return self
    }

    /// Sets identifier for constraint. This constraint can be easy to find with `constraints(with:)` function.
    func identifier(_ id: Identifier) -> Self {
        identifier = id.rawValue
        return self
    }
}
