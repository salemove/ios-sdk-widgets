import UIKit

public enum ThemeColorStyle {
    case `default`
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
