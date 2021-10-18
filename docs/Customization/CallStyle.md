
[order]: # (5)
# CallStyle

`call: CallStyle` is a property of `Theme` which is responsible for the video/audio call view appearance of the GliaWidgets. Customizing this property (or any of its individual sub-properties) allows to change how the call view looks down to each individual element, be it the header title, background color or call button icons.

There is a default call view configuration in GliaWidgets. It means that all of its properties have default values. For example, `audioTitle` is "Audio", `operatorNameFont` is `font.header1` ("Roboto Bold", 24pt) and `buttonBar.muteButton.active.imageColor` is `color.baseDark` (`#2C0735`).

`CallStyle` can be created with the following initializer:
```swift
let callStyle = CallStyle(
    header: HeaderStyle,
    connect: ConnectStyle,
    backgroundColor: UIColor,
    preferredStatusBarStyle: UIStatusBarStyle,
    audioTitle: String,
    videoTitle: String,
    operatorName: String,
    operatorNameFont: UIFont,
    operatorNameColor: UIColor,
    durationFont: UIFont,
    durationColor: UIColor,
    topText: String,
    topTextFont: UIFont,
    topTextColor: UIColor,
    bottomText: String,
    bottomTextFont: UIFont,
    bottomTextColor: UIColor,
    buttonBar: CallButtonBarStyle
)
```

It can then be assigned to the `call` property of the `Theme`:
```swift
let theme = Theme()

theme.call = callStyle
```

A more in-depth description of each individual property of the `CallStyle` can be found in the documentation comments in Xcode itself.

It is also possible to customize individual components directly, without creating an entire `CallStyle` or `Theme` yourself. This can be achieved by calling an empty initializer for `Theme` and changing its properties directly:
```swift
let theme = Theme() // create a default Theme

theme.call.audioTitle = "Voice"
theme.connect.queue.firstTextFontColor = .white
```

The default look of the audio call view in a connected state:

<p align="center">
  <img width="500" src="./images/call_general_look.png">
</p>
