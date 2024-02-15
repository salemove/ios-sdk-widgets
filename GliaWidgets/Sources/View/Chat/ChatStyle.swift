import UIKit

/// Style of the chat view.
public class ChatStyle: EngagementStyle {
    /// Title shown in the header.
    public var title: String

    /// Style of the message sent by the visitor.
    public var visitorMessageStyle: Theme.VisitorMessageStyle

    /// Style of the message sent by the operator.
    public var operatorMessageStyle: Theme.OperatorMessageStyle

    /// Style of the choice card sent to the visitor by the AI engine.
    public var choiceCardStyle: Theme.ChoiceCardStyle

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

    /// Header title for secure messaging transcript.
    public var secureTranscriptTitle: String

    /// Header style for secure messaging transcript.
    public var secureTranscriptHeader: HeaderStyle

    /// Style for divider of unread messages in secure messaging transcript.
    public var unreadMessageDivider: UnreadMessageDividerStyle

    /// Style of the system message
    public var systemMessageStyle: Theme.SystemMessageStyle

    /// Style of the Glia Virtual Assistant
    public var gliaVirtualAssistant: GliaVirtualAssistantStyle

    /// - Parameters:
    ///   - header: Style of the view's header (navigation bar area) when the screen is displaying live chat.
    ///   - connect: Styles for different engagement connection states.
    ///   - backgroundColor: View's background color.
    ///   - preferredStatusBarStyle: Preferred style of the status bar.
    ///   - title: Title shown in the header.
    ///   - visitorMessageStyle: Style of the message sent by the visitor.
    ///   - operatorMessageStyle: Style of the message sent by the operator.
    ///   - choiceCard: Style of the choice card sent to the visitor by the AI engine.
    ///   - messageEntry: Style of the message entry area on the bottom of the view.
    ///   - audioUpgrade: Style of the audio upgrade view.
    ///   - videoUpgrade: Style of the video upgrade view.
    ///   - callBubble: Style of the call bubble in chat (shown after upgrade to call).
    ///   - pickMedia: Style of the attachment media type picker.
    ///   - unreadMessageIndicator: Style of the unread message indicator.
    ///   - operatorTypingIndicator: Style of the view that indicates that the operator is currently typing.
    ///   - accessibility: Accessibility related properties.
    ///   - secureTranscriptTitle: Header title for secure messaging transcript.
    ///   - secureTranscriptHeader: Style of the view's header (navigation bar area) when the screen is displaying secure conversations.
    ///   - unreadMessageDivider: Style for divider of unread messages in secure messaging transcript.
    ///
    public init(
        header: HeaderStyle,
        connect: ConnectStyle,
        backgroundColor: ColorType,
        preferredStatusBarStyle: UIStatusBarStyle,
        title: String,
        visitorMessageStyle: Theme.VisitorMessageStyle,
        operatorMessageStyle: Theme.OperatorMessageStyle,
        choiceCardStyle: Theme.ChoiceCardStyle,
        messageEntry: ChatMessageEntryStyle,
        audioUpgrade: ChatCallUpgradeStyle,
        videoUpgrade: ChatCallUpgradeStyle,
        callBubble: BubbleStyle,
        pickMedia: AttachmentSourceListStyle,
        unreadMessageIndicator: UnreadMessageIndicatorStyle,
        operatorTypingIndicator: OperatorTypingIndicatorStyle,
        accessibility: Accessibility = .unsupported,
        secureTranscriptTitle: String,
        secureTranscriptHeader: HeaderStyle,
        unreadMessageDivider: UnreadMessageDividerStyle,
        systemMessageStyle: Theme.SystemMessageStyle,
        gliaVirtualAssistant: GliaVirtualAssistantStyle
    ) {
        self.title = title
        self.visitorMessageStyle = visitorMessageStyle
        self.operatorMessageStyle = operatorMessageStyle
        self.choiceCardStyle = choiceCardStyle
        self.messageEntry = messageEntry
        self.audioUpgrade = audioUpgrade
        self.videoUpgrade = videoUpgrade
        self.callBubble = callBubble
        self.pickMedia = pickMedia
        self.unreadMessageIndicator = unreadMessageIndicator
        self.operatorTypingIndicator = operatorTypingIndicator
        self.accessibility = accessibility
        self.secureTranscriptTitle = secureTranscriptTitle
        self.secureTranscriptHeader = secureTranscriptHeader
        self.unreadMessageDivider = unreadMessageDivider
        self.systemMessageStyle = systemMessageStyle
        self.gliaVirtualAssistant = gliaVirtualAssistant

        super.init(
            header: header,
            connect: connect,
            backgroundColor: backgroundColor,
            preferredStatusBarStyle: preferredStatusBarStyle
        )
    }
}
