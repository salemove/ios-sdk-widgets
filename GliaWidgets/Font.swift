import UIKit

enum Font {
    @available(*, deprecated, message: """
                Use Font.Style and UIFontMetrics via FontScaling instead of UIFont of specific size.
                For more information refer to 'ThemeFont.swift' to see it in action.
                """)
    static func regular(_ size: CGFloat) -> UIFont {
        FontProvider.shared.font(named: .robotoRegular, size: size)
    }

    @available(*, deprecated, message: """
                Use Font.Style and UIFontMetrics via FontScaling instead of UIFont of specific size.
                For more information refer to 'ThemeFont.swift' to see it in action.
                """)
    static func medium(_ size: CGFloat) -> UIFont {
        FontProvider.shared.font(named: .robotoMedium, size: size)
    }

    @available(*, deprecated, message: """
                Use Font.Style and UIFontMetrics via FontScaling instead of UIFont of specific size.
                For more information refer to 'ThemeFont.swift' to see it in action.
                """)
    static func bold(_ size: CGFloat) -> UIFont {
        FontProvider.shared.font(named: .robotoBold, size: size)
    }
}
