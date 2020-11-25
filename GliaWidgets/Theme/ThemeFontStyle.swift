import UIKit

public enum ThemeFontStyle {
    case `default`
    case avenir
    case custom(ThemeFont)
}

extension ThemeFontStyle {
    var font: ThemeFont {
        switch self {
        case .default:
            return ThemeFont(regular: Font.regular(1),
                             medium: Font.medium(1),
                             bold: Font.bold(1))
        case .avenir:
            return ThemeFont(regular: UIFont(name: "Avenir-Roman", size: 1),
                             medium: UIFont(name: "Avenir-Medium", size: 1),
                             bold: UIFont(name: "Avenir-Heavy", size: 1))
        case .custom(let font):
            return font
        }
    }
}
