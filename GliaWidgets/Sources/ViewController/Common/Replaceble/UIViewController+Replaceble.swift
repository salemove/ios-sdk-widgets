import UIKit

/// Indicating presentation priority of an alert.
/// Based on comparing values we can decide whether an alert can be replaced with another alert.
enum PresentationPriority: Int {
    /// Applicable for `message`, `singleMediaUpgrade` and `screenShareOffer` cases
    case regular
    /// Applicable for `confirmation` case
    case high
    /// Applicable for `singleAction` case
    case highest
}

protocol Replaceable where Self: UIViewController {
    var presentationPriority: PresentationPriority { get }
    func isReplaceable(with replaceable: Replaceable) -> Bool
}

extension Replaceable {
    var presentationPriority: PresentationPriority { .regular }

    func isReplaceable(with replaceable: Replaceable) -> Bool {
        presentationPriority.rawValue <= replaceable.presentationPriority.rawValue
    }
}
