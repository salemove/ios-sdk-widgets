#if DEBUG
extension Theme {
    static func mock(
        colorStyle: ThemeColorStyle = .default,
        fontStyle: ThemeFontStyle = .default
    ) -> Theme {
        .init(
            colorStyle: colorStyle,
            fontStyle: fontStyle
        )
    }
}
#endif
