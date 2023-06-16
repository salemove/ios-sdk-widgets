import UIKit

extension Array where Element == NSLayoutConstraint {
    /// Activates all constraints as a batch from array.
    public func activate() {
        NSLayoutConstraint.activate(self)
    }

    /// Deactivates all constraints from array.
    public func deactivate() {
        NSLayoutConstraint.deactivate(self)
    }

    /// Adds consatraint to array.
    public static func += (
        destination: inout [NSLayoutConstraint],
        newConstraint: NSLayoutConstraint
    ) {
        destination.append(newConstraint)
    }

    /// Returns constraints with specific identifier.
    public func constraints(with id: NSLayoutConstraint.Identifier) -> [NSLayoutConstraint] {
        filter { $0.identifier == id.rawValue }
    }
}

extension NSLayoutConstraint {
    /// Defines constraint identifier names.
    public enum Identifier: String {
        case leading, top, trailing, bottom, width, height, greaterThanTop, lessThanBottom
    }

    /// Sets priority for a constraint.
    public func priority(_ newValue: UILayoutPriority) -> Self {
        priority = newValue
        return self
    }

    /// Sets identifier for a constraint.
    public func identifier(_ id: Identifier) -> Self {
        identifier = id.rawValue
        return self
    }
}
