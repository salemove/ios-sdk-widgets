import SwiftUI
import GliaWidgets

struct ThemeColors {
    var primary: Color = Color(UIColor.systemBlue)
    var secondary: Color = Color(UIColor.systemGray)
    var baseNormal: Color = Color(UIColor.label)
    var baseLight: Color = Color(UIColor.systemBackground)
    var baseDark: Color = Color(UIColor.darkGray)
    var baseShade: Color = Color(UIColor.systemGray5)
    var systemNegative: Color = Color(UIColor.systemRed)

    init() {}

    init(from theme: Theme) {
        primary = Color(theme.color.primary)
        secondary = Color(theme.color.secondary)
        baseNormal = Color(theme.color.baseNormal)
        baseLight = Color(theme.color.baseLight)
        baseDark = Color(theme.color.baseDark)
        baseShade = Color(theme.color.baseShade)
        systemNegative = Color(theme.color.systemNegative)
    }

    func toThemeColor() -> ThemeColor {
        ThemeColor(
            primary: UIColor(primary),
            secondary: UIColor(secondary),
            baseNormal: UIColor(baseNormal),
            baseLight: UIColor(baseLight),
            baseDark: UIColor(baseDark),
            baseShade: UIColor(baseShade),
            systemNegative: UIColor(systemNegative)
        )
    }
}
