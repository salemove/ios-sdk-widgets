
[order]: # (8)
# BubbleStyle

`minimizedBubble: BubbleStyle` is a `Theme` property that is responsible for the appearance of a minimized chat/call bubble. This bubble appears when some view of the GliaWidgets (or the enirety of the Widgets) is minimized. It can be dragged around the screen at user's will. `BubbleStyle` allows for customization of the user (operator) image and the unread messages badge style.

There is a default bubble configuration in GliaWidgets. It means that all of its properties have default values. For example, `userImage.placeholderColor` is `color.baseLight` (#FFFFFF) and `badge.font` is `font.caption` ("Roboto Regular", 12 pt).

`BubbleStyle` can be created with the following initializer:
```swift
let bubble = BubbleStyle(
    userImage: UserImageStyle,
    badge: BadgeStyle
)
```

It can then be assigned to the `Theme`'s `minimizedBubble` property:
```swift
let theme = Theme()

theme.minimizedBubble = bubble
```

It is also possible to customize individual components directly, without creating an entire `BubbleStyle` or `Theme` yourself. This can be achieved by calling an empty initializer for `Theme` and changing its properties directly:
```swift
let theme = Theme() // create a default Theme

theme.minimizedBubble.userImage.placeholderColor = .black
theme.minimizedBubble.badge.font = .systemFont(ofSize: 10)
```

Below is the default appearance of the chat/call bubble if the operator has an avatar set in the Glia Hub:

<p align="center">
  <img src="./images/bubble_with_avatar.png">
</p>

If the operator does not have an avatar, a customizable placeholder is displayed:

<p align="center">
  <img src="./images/bubble_customization.png">
</p>
