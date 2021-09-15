
[order]: # (4)
# ChatStyle

`chat: ChatStyle` is a property of `Theme` which is responsible for the chat appearance of the GliaWidgets. Customizing this property allows to change how the chat view looks down to each individual element, be it the header title, attachment selection button or message input area placeholder.

There is a default chat configuration that exists in GliaWidgets. It means that all of the elements have default values. For example, `title` is "Chat", `visitorMessage.statusFont` is "Roboto Regular", 12pt and `callBubble.badge.fontColor` is #FFFFFF.

`ChatStyle` can be created via the following initializer and assigned to `chat` property of `Theme`:
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

Below is a visual representation of some of the customization properties of the GliaWidgets chat.

[[images/chat_customization.png]]
