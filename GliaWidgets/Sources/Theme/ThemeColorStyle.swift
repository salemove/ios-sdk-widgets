import UIKit

/// Color style of a theme.
public enum ThemeColorStyle {
    /// Default color style
    case `default`
    /// Custom color style
    case custom(ThemeColor)
}

extension ThemeColorStyle {
    var color: ThemeColor {
        switch self {
        case .default:
            return ThemeColor()
        case .custom(let color):
            return color
        }
    }
}
