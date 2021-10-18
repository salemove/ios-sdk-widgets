
[order]: # (1)
# Creating a Theme

A theme is what describes GliaWidgets' UI appearance.

A theme can be created with a `ThemeColorStyle` and `ThemeFontStyle`:
```swift
let colorStyle: ThemeColorStyle = .custom(color) // color is a variable of type ThemeColor
let fontStyle: ThemeFontStyle = .custom(font) // font is a variable of type ThemeFont

let theme = Theme(
    colorStyle: colorStyle,
    fontStyle: fontStyle
)
```

After creation, theme's appearance can be customized through its properties. More information about them can be found in other pages from the Customization category.

**NB!** `Theme`'s initializer also has a `showsPoweredBy` parameter. It controls whether the dialogs show the "Powered by Glia" logo at the bottom. The use of this parameter must be agreed with the Glia representatives. Default value is `true`.
