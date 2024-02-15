import UIKit

/// Defines the color type for UI elements which can be either a solid fill or a gradient.
public enum ColorType: Equatable {
    /// Represents a solid fill color.
    /// - Parameters:
    ///   - color: The `UIColor` used for the fill.
    ///
    case fill(color: UIColor)

    /// Represents a gradient color.
    /// - Parameters:
    ///  - colors: An array of `CGColor` representing the gradient colors.
    ///
    case gradient(colors: [CGColor])

    var color: UIColor {
        switch self {
        case let .fill(color):
            return color
        case let .gradient(colors):
            return UIColor(cgColor: colors.first ?? .clear)
        }
    }
}
