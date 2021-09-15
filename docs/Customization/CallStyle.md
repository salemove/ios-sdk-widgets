
[order]: # (5)
# CallStyle

`call: CallStyle` is a property of `Theme` which is responsible for the video/audio call view appearance of the GliaWidgets. Customizing this property allows to change how the call view looks down to each individual element, be it the header title, background color or call button icons.

There is a default call view configuration that exists in GliaWidgets. It means that all of the elements have default values. For example, `audioTitle` is "Audio", `operatorNameFont` is "Roboto Bold", 24pt and `buttonBar.muteButton.imageColor` is #2C0735.

`CallStyle` can be created via the following initializer and assigned to `call` property of `Theme`:
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

The general default look of the audio call view:

<p align="center">
  <img width="500" src="./images/call_general_view.png">
</p>
