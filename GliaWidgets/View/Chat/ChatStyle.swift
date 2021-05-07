import UIKit

public class ChatStyle: EngagementStyle {
    public var title: String
    public var backButton: HeaderButtonStyle
    public var closeButton: HeaderButtonStyle
    public var visitorMessage: VisitorChatMessageStyle
    public var operatorMessage: OperatorChatMessageStyle
    public var choiceCard: ChoiceCardStyle
    public var messageEntry: ChatMessageEntryStyle
    public var audioUpgrade: ChatCallUpgradeStyle
    public var videoUpgrade: ChatCallUpgradeStyle
    public var callBubble: BubbleStyle
    public var pickMedia: ItemListStyle
    public var newMessageIndicator: NewMessageIndicatorStyle

    public init(
        header: HeaderStyle,
        connect: ConnectStyle,
        backgroundColor: UIColor,
        endButton: ActionButtonStyle,
        endScreenShareButton: HeaderButtonStyle,
        preferredStatusBarStyle: UIStatusBarStyle,
        title: String,
        backButton: HeaderButtonStyle,
        closeButton: HeaderButtonStyle,
        visitorMessage: VisitorChatMessageStyle,
        operatorMessage: OperatorChatMessageStyle,
        choiceCard: ChoiceCardStyle,
        messageEntry: ChatMessageEntryStyle,
        audioUpgrade: ChatCallUpgradeStyle,
        videoUpgrade: ChatCallUpgradeStyle,
        callBubble: BubbleStyle,
        pickMedia: ItemListStyle,
        newMessageIndicator: NewMessageIndicatorStyle
    ) {
        self.title = title
        self.backButton = backButton
        self.closeButton = closeButton
        self.visitorMessage = visitorMessage
        self.operatorMessage = operatorMessage
        self.choiceCard = choiceCard
        self.messageEntry = messageEntry
        self.audioUpgrade = audioUpgrade
        self.videoUpgrade = videoUpgrade
        self.callBubble = callBubble
        self.pickMedia = pickMedia
        self.newMessageIndicator = newMessageIndicator
        super.init(
            header: header,
            connect: connect,
            backgroundColor: backgroundColor,
            endButton: endButton,
            endScreenShareButton: endScreenShareButton,
            preferredStatusBarStyle: preferredStatusBarStyle
        )
    }
}
