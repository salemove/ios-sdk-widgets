#if DEBUG
extension Theme {
    static func mock(
        colorStyle: ThemeColorStyle = .default,
        fontStyle: ThemeFontStyle = .default,
        showsPoweredBy: Bool = true
    ) -> Theme {
        .init(
            colorStyle: colorStyle,
            fontStyle: fontStyle,
            showsPoweredBy: showsPoweredBy
        )
    }
}
#endif
