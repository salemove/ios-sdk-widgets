import UIKit

public enum ThemeFontStyle {
    case `default`
    case defaultLarge
    case custom(ThemeFont)
}

extension ThemeFontStyle {
    var font: ThemeFont {
        switch self {
        case .default:
            return ThemeFont()
        case .defaultLarge:
            return ThemeFont(
                header1: Font.bold(26),
                header2: Font.regular(22),
                header3: Font.medium(20),
                bodyText: Font.regular(18),
                subtitle: Font.regular(16),
                caption: Font.regular(14)
            )
        case .custom(let font):
            return font
        }
    }
}
