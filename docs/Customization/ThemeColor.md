
[order]: # (2)
# ThemeColor

`color: ThemeColor` is a property of `Theme` which is responsible for the color palette of the GliaWidgets. This allows for the most basic customization, without even touching the more advanced parts such as icons or fonts.

There is a default configuration in GliaWidgets. It means that all of the colors (such as `primary`, `baseDark` or `systemNegative`) have default values, as well as UI elements that use them by default. For example, chat, message input area and alerts use `background` (which has a default value of #FFFFFF) as their background color.

This, however, does not mean that elements are bound to use a specific color. Any color can be attached to any element via specific theme properties.

As mentioned above, the default colors are not defined directly for each individual element. Instead, some common colors are defined as a single entity (e.g. `primary` or `background`) which are then assigned to one or several UI elements. These definitions can be found in the file `Color.swift`.

`ThemeColor` can be created with the following initializer:
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

It can then be used in the `Theme`'s initializer:
```swift
let color = ThemeColor(primary: .blue, secondary: .red, ...)
let colorStyle = ThemeColorStyle.custom(color)
let theme = Theme(colorStyle: colorStyle, fontStyle: .default)
```

It is also possible to customize individual components directly, without creating an entire `ThemeColor` or `Theme` yourself. This can be achieved by calling an empty initializer for `Theme` and changing its properties directly:
```swift
let theme = Theme() // create a default Theme

theme.chat.unreadMessageIndicator.badge.backgroundColor = .brown
theme.call.header.backgroundColor = .red
theme.alert.positiveAction.backgroundColor = .green
```

**NB!** It is not possible to directly change the values of the `color` property of the `Theme`. To change the colors across the entire app, `ThemeColor`'s initializer should be used. If there is still a need to change only some specific colors, other parameters can be omitted. The omitted parameters will use the default values.
 ```swift
var theme = Theme()

theme.color.baseNormal = .black // Not possible!

// Correct way
let color = ThemeColor(baseNormal: .black) // All of the other colors will use the default values
theme = Theme(colorStyle: .custom(font)) // Fonts will have the default values
```

Below are some examples of the default colors used in the app. Most of the colors labeled have the color name (as seen in GliaWidgets' `Color.swift`) and its HEX value.

<p align="center">
  <img width="250" src="./images/chat_colors.png">
  <img width="250" src="./images/alert_colors.png">
  <img width="250" src="./images/call_colors.png">
</p>
