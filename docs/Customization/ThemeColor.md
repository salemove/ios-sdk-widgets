
[order]: # (2)
# ThemeColor

`colorStyle: ThemeColor` is a property of `Theme` which is responsible for the color palette of the GliaWidgets. This allows for the most basic customization, without even touching the more advanced parts such as icons or fonts.

There is a default configuration that exists in GliaWidgets. It means that all of the colors (such as `primary`, `baseDark` or `systemNegative`) have default values, as well as UI elements that use them by default. For example, chat, message input area and alerts use `background` (which has a default value of #FFFFFF) as their background color.

This, however, does not mean that elements are bound to use a specific color. Any color can be attached to any element via specific theme properties.

`ThemeColor` can be created through the following initializer and used in `Theme`'s own initializer:
```swift
let color = ThemeColor(
    primary: UIColor,
    secondary: UIColor,
    baseNormal: UIColor,
    baseLight: UIColor,
    baseDark: UIColor,
    baseShade: UIColor,
    background: UIColor,
    systemNegative: UIColor,
)
```
