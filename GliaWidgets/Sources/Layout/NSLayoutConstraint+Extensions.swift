import UIKit

extension Array where Element == NSLayoutConstraint {
    /// Activates all constraints as a batch from array.
    func activate() {
        NSLayoutConstraint.activate(self)
    }

    /// Deactivates all constraints from array.
    func deactivate() {
        NSLayoutConstraint.deactivate(self)
    }

    /// Adds constraint to array.
    static func += (
        destination: inout [NSLayoutConstraint],
        newConstraint: NSLayoutConstraint
    ) {
        destination.append(newConstraint)
    }

    /// Returns constraints with specific identifier.
    func constraints(with id: NSLayoutConstraint.Identifier) -> [NSLayoutConstraint] {
        filter { $0.identifier == id.rawValue }
    }
}

extension NSLayoutConstraint {
    /// Defines constraint identifier names.
    enum Identifier: String {
        case leading, top, trailing, bottom, width, height, greaterThanTop, lessThanBottom
    }

    /// Sets priority for a constraint.
    func priority(_ newValue: UILayoutPriority) -> Self {
        priority = newValue
        return self
    }

    /// Sets identifier for a constraint.
    func identifier(_ id: Identifier) -> Self {
        identifier = id.rawValue
        return self
    }
}
