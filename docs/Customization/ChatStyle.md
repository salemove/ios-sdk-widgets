
[order]: # (4)
# ChatStyle

`chat: ChatStyle` is a property of `Theme` which is responsible for the chat appearance of the GliaWidgets. Customizing this property (or any of its individual sub-properties) allows to change how the chat view looks down to each individual element, be it the header title, attachment selection button or message input area placeholder text.

There is a default chat configuration in GliaWidgets. It means that all of its properties have default values. For example, `title` is "Chat", `visitorMessage.statusFont` is `font.caption` ("Roboto Regular", 12pt) and `callBubble.badge.fontColor` is `color.baseLight` (`#FFFFFF`).

`ChatStyle` can be created with the following initializer:
```swift
let chatStyle = ChatStyle(
    header: HeaderStyle,
    connect: ConnectStyle,
    backgroundColor: UIColor,
    preferredStatusBarStyle: UIStatusBarStyle,
    title: String,
    visitorMessage: VisitorChatMessageStyle,
    operatorMessage: OperatorChatMessageStyle,
    choiceCard: ChoiceCardStyle,
    messageEntry: ChatMessageEntryStyle,
    audioUpgrade: ChatCallUpgradeStyle,
    videoUpgrade: ChatCallUpgradeStyle,
    callBubble: BubbleStyle,
    pickMedia: AttachmentSourceListStyle,
    unreadMessageIndicator: UnreadMessageIndicatorStyle
)
```

It can then be assigned to the `chat` property of the `Theme`:
```swift
let theme = Theme()

theme.chat = chatStyle
```

A more in-depth description of each individual property of the `ChatStyle` can be found in the documentation comments in Xcode itself.

It is also possible to customize individual components directly, without creating an entire `ChatStyle` or `Theme` yourself. This can be achieved by calling an empty initializer for `Theme` and changing its properties directly:
```swift
let theme = Theme() // create a default Theme

theme.chat.title = "Messaging"
theme.chat.backgroundColor = UIColor.blue
```

Below is a visual representation of some of the customization properties of the GliaWidgets chat.

<p align="center">
  <img width="500" src="./images/chat_customization.png">
</p>
