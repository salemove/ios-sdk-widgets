
[order]: # (6)
# AlertStyle

`alert: AlertStyle` is a property of `Theme` that is responsible for basic common appearance of alerts that appear in GliaWidgets, such as media upgrade or screen sharing offer. It allows to customize the title font, color and icon color; message font and color; background color, close button color; positive and negative button style.

It can be created via the following initializer and assigned to `alert` property of `Theme`:
```swift
public init(
    titleFont: UIFont,
    titleColor: UIColor,
    titleImageColor: UIColor,
    messageFont: UIFont,
    messageColor: UIColor,
    backgroundColor: UIColor,
    closeButtonColor: UIColor,
    positiveAction: ActionButtonStyle,
    negativeAction: ActionButtonStyle
)
```
