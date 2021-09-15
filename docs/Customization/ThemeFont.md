
[order]: # (3)
# ThemeFont

`fontStyle: ThemeFont` is a property of `Theme` which is responsible for font families and sizes of the GliaWidgets. Customizing this property allows to change the font of any label present in the GiaWidgets, be it visitor message text or "End Engagement" button label text.

There is a default configuration that exists in GliaWidgets. It means that all of the fonts (such as `header1`, `bodyText` or `buttonLabel`) have default values, as well as UI elements that use them by default. For example, visitor and operator message text, media upgrade texts use `bodyText` (which has a default value of "Roboto Regular", 18pt) as their default font.

This, however, does not mean that that elements are bound to use a specific font. Any font can be attached to any element via specific theme properties.

`ThemeFont` can be created through the following initializer and used in `Theme`'s own initializer:
```swift
let font = ThemeFont(
    header1: UIFont,
    header2: UIFont,
    header3: UIFont,
    bodyText: UIFont,
    subtitle: UIFont,
    mediumSubtitle: UIFont,
    caption: UIFont,
    buttonLabel: UIFont
)
```
