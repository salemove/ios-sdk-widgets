
[order]: # (6)
# AlertStyle

`alert: AlertStyle` is a property of `Theme` that is responsible for basic common appearance of alerts that appear in GliaWidgets, such as media upgrade or screen sharing offer. It allows to customize the title font and color, icon color, message font and color, background color, close button color and positive and negative button style.

It can be created with the following initializer:
```swift
let alertStyle = AlertStyle(
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

It can then be assigned to the `alert` property of the `Theme`:
```swift
let theme = Theme()

theme.alert = alertStyle
```

A more in-depth description of each individual property of the `AlertStyle` can be found in the documentation comments in Xcode itself.

It is also possible to customize individual components directly, without creating an entire `AlertStyle` or `Theme` yourself. This can be achieved by calling an empty initializer for `Theme` and changing its properties directly:
```swift
let theme = Theme() // create a default Theme

theme.alert.titleFont = .systemFont(ofSize: 14)
theme.alert.positiveAction.title = "Accept"
```

Below is the default appearance of the audio upgrade alert in the chat initiated from the Glia Hub:

<p align="center">
  <img width="500" src="./images/alert_general_look.png">
</p>
