
[order]: # (1)
# Creating a Theme

## Theme
A theme is what describes GliaWidgets' UI appearance.

A theme can be created with a `ThemeColorStyle` and `ThemeFontStyle` as such:
```swift
let color = ThemeColor(
    primary: primaryColorCell.color,
    secondary: secondaryColor,
    baseNormal: baseNormalColor,
    baseLight: baseLightColor,
    baseDark: baseDarkColor,
    baseShade: baseShadeColor,
    background: backgroundColor,
    systemNegative: systemNegativeColor,
)
let font = ThemeFont(
    header1: header1Font,
    header2: header2Font,
    header3: header3Font,
    bodyText: bodyTextFont,
    subtitle: subtitleFont,
    mediumSubtitle: mediumSubtitleFont,
    caption: captionFont,
    buttonLabel: buttonLabelFont
)

let colorStyle: ThemeColorStyle = .custom(color)
let fontStyle: ThemeFontStyle = .custom(font)

let theme = Theme(
    colorStyle: colorStyle,
    fontStyle: fontStyle
)
```

After creation, theme's appearance can be customized through its customizable properties.

### ThemeColor

### ThemeFont

### ChatStyle

### CallStyle

### AlertStyle

### AlertConfiguration

### BubbleStyle
