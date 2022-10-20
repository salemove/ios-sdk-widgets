import UIKit

/// Style of the chat view.
public class ChatStyle: EngagementStyle {
    /// Title shown in the header.
    public var title: String

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

    /// Style of the view that indicates that the operator is currently typing.
    public var operatorTypingIndicator: OperatorTypingIndicatorStyle

    /// Accessibility related properties.
    public var accessibility: Accessibility

    ///
    /// - Parameters:
    ///   - header: Style of the view's header (navigation bar area).
    ///   - connect: Styles for different engagement connection states.
    ///   - backgroundColor: View's background color.
    ///   - preferredStatusBarStyle: Preferred style of the status bar.
    ///   - title: Title shown in the header.
    ///   - visitorMessage: Style of the message sent by the visitor.
    ///   - operatorMessage: Style of the message sent by the operator.
    ///   - choiceCard: Style of the choice card sent to the visitor by the AI engine.
    ///   - messageEntry: Style of the message entry area on the bottom of the view.
    ///   - audioUpgrade: Style of the audio upgrade view.
    ///   - videoUpgrade: Style of the video upgrade view.
    ///   - callBubble: Style of the call bubble in chat (shown after upgrade to call).
    ///   - pickMedia: Style of the attachment media type picker.
    ///   - unreadMessageIndicator: Style of the unread message indicator.
    ///   - operatorTypingIndicator: Style of the view that indicates that the operator is currently typing.
    ///   - accessibility: Accessibility related properties.
    ///
    public init(
        header: HeaderStyle,
        connect: ConnectStyle,
        backgroundColor: ColorType,
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
        unreadMessageIndicator: UnreadMessageIndicatorStyle,
        operatorTypingIndicator: OperatorTypingIndicatorStyle,
        accessibility: Accessibility = .unsupported
    ) {
        self.title = title
        self.visitorMessage = visitorMessage
        self.operatorMessage = operatorMessage
        self.choiceCard = choiceCard
        self.messageEntry = messageEntry
        self.audioUpgrade = audioUpgrade
        self.videoUpgrade = videoUpgrade
        self.callBubble = callBubble
        self.pickMedia = pickMedia
        self.unreadMessageIndicator = unreadMessageIndicator
        self.operatorTypingIndicator = operatorTypingIndicator
        self.accessibility = accessibility
        super.init(
            header: header,
            connect: connect,
            backgroundColor: backgroundColor,
            preferredStatusBarStyle: preferredStatusBarStyle
        )
    }

    func apply(configuration: RemoteConfiguration.Chat?) {
        header.apply(configuration: configuration?.header)
        connect.apply(configuration: configuration?.connect)
        visitorMessage.apply(configuration: configuration?.visitorMessage)
        operatorMessage.apply(configuration: configuration?.operatorMessage)
        messageEntry.apply(configuration: configuration?.input)
        choiceCard.apply(configuration: configuration?.responseCard)
        audioUpgrade.apply(configuration: configuration?.audioUpgrade)
        videoUpgrade.apply(configuration: configuration?.videoUpgrade)
        callBubble.apply(configuration: configuration?.bubble)
        pickMedia.apply(configuration: configuration?.attachmentSourceList)
        unreadMessageIndicator.apply(configuration: configuration?.unreadIndicator)
        operatorTypingIndicator.apply(configuration: configuration?.typingIndicator)

        configuration?.background?.color.map {
            switch $0.type {
            case .fill:
                $0.value
                    .map { UIColor(hex: $0) }
                    .first
                    .map { backgroundColor = .fill(color: $0) }
            case .gradient:
                let colors = $0.value.convertToCgColors()
                backgroundColor = .gradient(colors: colors)
            }
        }
    }
}
