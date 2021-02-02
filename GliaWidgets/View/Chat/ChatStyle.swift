import UIKit

public class ChatStyle: EngagementStyle {
    public var title: String
    public var visitorMessage: VisitorChatMessageStyle
    public var operatorMessage: OperatorChatMessageStyle
    public var messageEntry: ChatMessageEntryStyle
    public var audioUpgrade: ChatMediaUpgradeStyle
    public var videoUpgrade: ChatMediaUpgradeStyle
    public var callBubble: BubbleStyle

    public init(header: HeaderStyle,
                connect: ConnectStyle,
                backgroundColor: UIColor,
                endButton: ActionButtonStyle,
                preferredStatusBarStyle: UIStatusBarStyle,
                title: String,
                visitorMessage: VisitorChatMessageStyle,
                operatorMessage: OperatorChatMessageStyle,
                messageEntry: ChatMessageEntryStyle,
                audioUpgrade: ChatMediaUpgradeStyle,
                videoUpgrade: ChatMediaUpgradeStyle,
                callBubble: BubbleStyle) {
        self.title = title
        self.visitorMessage = visitorMessage
        self.operatorMessage = operatorMessage
        self.messageEntry = messageEntry
        self.audioUpgrade = audioUpgrade
        self.videoUpgrade = videoUpgrade
        self.callBubble = callBubble
        super.init(header: header,
                   connect: connect,
                   backgroundColor: backgroundColor,
                   endButton: endButton,
                   preferredStatusBarStyle: preferredStatusBarStyle)
    }
}
