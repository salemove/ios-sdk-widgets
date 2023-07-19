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

    /// Header title for secure messaging transcript.
    public var secureTranscriptTitle: String

    /// Header style for secure messaging transcript.
    public var secureTranscriptHeader: HeaderStyle

    /// Style for divider of unread messages in secure messaging transcript.
    public var unreadMessageDivider: UnreadMessageDividerStyle

    /// Style of the system message
    public var systemMessage: SystemMessageStyle

    /// Style of the Glia Virtual Assistant
    public var gliaVirtualAssistant: GliaVirtualAssistantStyle

    ///
    /// - Parameters:
    ///   - header: Style of the view's header (navigation bar area) when the screen is displaying live chat.
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
    ///   - secureTranscriptTitle: Header title for secure messaging transcript.
    ///   - secureTranscriptHeader: Style of the view's header (navigation bar area) when the screen is displaying secure conversations.
    ///   - unreadMessageDivider: Style for divider of unread messages in secure messaging transcript.
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
        accessibility: Accessibility = .unsupported,
        secureTranscriptTitle: String,
        secureTranscriptHeader: HeaderStyle,
        unreadMessageDivider: UnreadMessageDividerStyle,
        systemMessage: SystemMessageStyle,
        gliaVirtualAssistant: GliaVirtualAssistantStyle
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
        self.secureTranscriptTitle = secureTranscriptTitle
        self.secureTranscriptHeader = secureTranscriptHeader
        self.unreadMessageDivider = unreadMessageDivider
        self.systemMessage = systemMessage
        self.gliaVirtualAssistant = gliaVirtualAssistant

        super.init(
            header: header,
            connect: connect,
            backgroundColor: backgroundColor,
            preferredStatusBarStyle: preferredStatusBarStyle
        )
    }

    // swiftlint:disable function_body_length
    func apply(
        configuration: RemoteConfiguration.Chat?,
        assetsBuilder: RemoteConfiguration.AssetsBuilder
    ) {
        header.apply(
            configuration: configuration?.header,
            assetsBuilder: assetsBuilder
        )
        connect.apply(
            configuration: configuration?.connect,
            assetsBuilder: assetsBuilder
        )
        visitorMessage.apply(
            configuration: configuration?.visitorMessage,
            assetsBuilder: assetsBuilder
        )
        operatorMessage.apply(
            configuration: configuration?.operatorMessage,
            assetsBuilder: assetsBuilder
        )
        messageEntry.apply(
            configuration: configuration?.input,
            assetsBuilder: assetsBuilder
        )
        choiceCard.apply(
            configuration: configuration?.responseCard,
            assetsBuilder: assetsBuilder
        )
        audioUpgrade.apply(
            configuration: configuration?.audioUpgrade,
            assetsBuilder: assetsBuilder
        )
        videoUpgrade.apply(
            configuration: configuration?.videoUpgrade,
            assetsBuilder: assetsBuilder
        )
        callBubble.apply(
            configuration: configuration?.bubble,
            assetsBuilder: assetsBuilder
        )
        pickMedia.apply(
            configuration: configuration?.attachmentSourceList,
            assetsBuilder: assetsBuilder
        )
        unreadMessageIndicator.apply(
            configuration: configuration?.unreadIndicator,
            assetsBuilder: assetsBuilder
        )
        operatorTypingIndicator.apply(configuration: configuration?.typingIndicator)
        unreadMessageDivider.apply(
            lineColor: configuration?.newMessagesDividerColor,
            text: configuration?.newMessagesDividerText,
            assetBuilder: assetsBuilder
        )
        systemMessage.apply(
            configuration: configuration?.systemMessage,
            assetsBuilder: assetsBuilder
        )

        gliaVirtualAssistant.apply(
            configuration: configuration?.gva,
            assetBuilder: assetsBuilder
        )

        configuration?.background?.color.unwrap {
            switch $0.type {
            case .fill:
                $0.value
                    .map { UIColor(hex: $0) }
                    .first
                    .unwrap { backgroundColor = .fill(color: $0) }
            case .gradient:
                let colors = $0.value.convertToCgColors()
                backgroundColor = .gradient(colors: colors)
            }
        }
    }
    // swiftlint:enable function_body_length
}
