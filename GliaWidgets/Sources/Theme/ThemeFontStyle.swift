import UIKit

/// Font style of a theme.
public enum ThemeFontStyle {
    /// Default font style
    case `default`

    /// Default large font style - based on the default style with slightly larger fonts
    case defaultLarge

    /// Custom font style
    case custom(ThemeFont)
}

extension ThemeFontStyle {
    var font: ThemeFont {
        switch self {
        case .default:
            return ThemeFont()
        case .defaultLarge:
            return ThemeFont(
                header1: UIFont.systemFont(ofSize: 26, weight: .bold),
                header2: UIFont.systemFont(ofSize: 22, weight: .regular),
                header3: UIFont.systemFont(ofSize: 20, weight: .medium),
                bodyText: UIFont.systemFont(ofSize: 18, weight: .regular),
                subtitle: UIFont.systemFont(ofSize: 16, weight: .regular),
                caption: UIFont.systemFont(ofSize: 14, weight: .regular)
            )
        case .custom(let font):
            return font
        }
    }
}
