import UIKit

/// Style of the chat view.
public class ChatStyle: EngagementStyle {
    /// Title shown in the header.
    public var title: String

    /// Back button style in the header.
    public var backButton: HeaderButtonStyle

    /// Close button style in the header.
    public var closeButton: HeaderButtonStyle

    /// Style of the message sent by the visitor.
    public var visitorMessage: VisitorChatMessageStyle

    /// Style of the message sent by the operator.
    public var operatorMessage: OperatorChatMessageStyle

    /// Style of the choice card sent to the visitor by the AI engine.
    public var choiceCard: ChoiceCardStyle

    /// Style of the message entry area on the bottom of the view.
    public var messageEntry: ChatMessageEntryStyle

    /// Style of the audio upgrade view.
    public var audioUpgrade: ChatCallUpgradeStyle

    /// Style of the video upgrade view.
    public var videoUpgrade: ChatCallUpgradeStyle

    /// Style of the call bubble in chat (shown after upgrade to call).
    public var callBubble: BubbleStyle

    /// Style of the list that contains the chat attachment sources. Appears in the media upload menu popover in the message input area in chat.
    public var pickMedia: AttachmentSourceListStyle

    /// Style of the unread message indicator.
    public var unreadMessageIndicator: UnreadMessageIndicatorStyle

    ///
    /// - Parameters:
    ///   - header: Style of the view's header (navigation bar area).
    ///   - connect: Styles for different engagement connection states.
    ///   - backgroundColor: View's background color.
    ///   - endButton: Style of the engagement ending button.
    ///   - endScreenShareButton: Style of the screen sharing ending button.
    ///   - preferredStatusBarStyle: Preferred style of the status bar.
    ///   - title: Title shown in the header.
    ///   - backButton: Back button style in the header.
    ///   - closeButton: Close button style in the header.
    ///   - visitorMessage: Style of the message sent by the visitor.
    ///   - operatorMessage: Style of the message sent by the operator.
    ///   - choiceCard: Style of the choice card sent to the visitor by the AI engine.
    ///   - messageEntry: Style of the message entry area on the bottom of the view.
    ///   - audioUpgrade: Style of the audio upgrade view.
    ///   - videoUpgrade: Style of the video upgrade view.
    ///   - callBubble: Style of the call bubble in chat (shown after upgrade to call).
    ///   - pickMedia: Style of the attachment media type picker.
    ///   - unreadMessageIndicator: Style of the unread message indicator.
    ///
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
        pickMedia: AttachmentSourceListStyle,
        unreadMessageIndicator: UnreadMessageIndicatorStyle
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
        self.unreadMessageIndicator = unreadMessageIndicator
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
