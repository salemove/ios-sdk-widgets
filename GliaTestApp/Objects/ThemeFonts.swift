import SwiftUI
import GliaWidgets

struct ThemeFonts {
    var header1: UIFont = UIFont.systemFont(ofSize: 28, weight: .bold)
    var header2: UIFont = UIFont.systemFont(ofSize: 24, weight: .semibold)
    var header3: UIFont = UIFont.systemFont(ofSize: 20, weight: .semibold)
    var bodyText: UIFont = UIFont.systemFont(ofSize: 16)
    var subtitle: UIFont = UIFont.systemFont(ofSize: 14)
    var mediumSubtitle1: UIFont = UIFont.systemFont(ofSize: 14, weight: .medium)
    var mediumSubtitle2: UIFont = UIFont.systemFont(ofSize: 12, weight: .medium)
    var caption: UIFont = UIFont.systemFont(ofSize: 12)
    var buttonLabel: UIFont = UIFont.systemFont(ofSize: 16, weight: .semibold)

    init() {}

    init(from theme: Theme) {
        header1 = theme.font.header1
        header2 = theme.font.header2
        header3 = theme.font.header3
        bodyText = theme.font.bodyText
        subtitle = theme.font.subtitle
        mediumSubtitle1 = theme.font.mediumSubtitle1
        mediumSubtitle2 = theme.font.mediumSubtitle2
        caption = theme.font.caption
        buttonLabel = theme.font.buttonLabel
    }

    func toThemeFont() -> ThemeFont {
        ThemeFont(
            header1: header1,
            header2: header2,
            header3: header3,
            bodyText: bodyText,
            subtitle: subtitle,
            mediumSubtitle1: mediumSubtitle1,
            mediumSubtitle2: mediumSubtitle2,
            caption: caption,
            buttonLabel: buttonLabel
        )
    }
}
