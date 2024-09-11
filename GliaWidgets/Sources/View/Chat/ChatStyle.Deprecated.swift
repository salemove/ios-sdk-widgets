import UIKit

extension ChatStyle {
    /// Deprecated. Style of the message sent by the operator.
    @available(*, deprecated, message: "Deprecated, use ``ChatStyle.operatorMessageStyle`` instead.")
    public var operatorMessage: OperatorChatMessageStyle {
        get {
            operatorMessageStyle.toOldOperatorMessageStyle()
        }
        set {
            operatorMessageStyle = newValue.toNewOperatorMessageStyle()
        }
    }

    /// Deprecated. Style of the system message
    @available(*, deprecated, message: "Deprecated, use ``ChatStyle.systemMessageStyle`` instead.")
    public var systemMessage: SystemMessageStyle {
        get {
            systemMessageStyle.toOldSystemMessageStyle()
        }
        set {
            systemMessageStyle = newValue.toNewSystemMessageStyle()
        }
    }

    /// Deprecated. Style of the message sent by the visitor.
    @available(*, deprecated, message: "Deprecated, use ``ChatStyle.visitorMessageStyle`` instead.")
    public var visitorMessage: VisitorChatMessageStyle {
        get {
            visitorMessageStyle.toOldVisitorMessageStyle()
        }
        set {
            visitorMessageStyle = newValue.toNewVisitorMessageStyle()
        }
    }

    /// Deprecated. Style of the choice card sent to the visitor by the AI engine.
    @available(*, deprecated, message: "Deprecated, use ``ChatStyle.choiceCardStyle`` instead.")
    public var choiceCard: ChoiceCardStyle {
        get {
            choiceCardStyle.toOldChoiceCardStyle()
        }
        set {
            choiceCardStyle = newValue.toNewChoiceCardStyle()
        }
    }

    /// Deprecated.
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
    @available(*, deprecated, message: "Deprecated, use designated initializer instead.")
    public convenience init(
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
        self.init(
            header: header,
            connect: connect,
            backgroundColor: backgroundColor,
            preferredStatusBarStyle: preferredStatusBarStyle,
            title: title,
            visitorMessageStyle: visitorMessage.toNewVisitorMessageStyle(),
            operatorMessageStyle: operatorMessage.toNewOperatorMessageStyle(),
            choiceCardStyle: choiceCard.toNewChoiceCardStyle(),
            messageEntry: messageEntry,
            audioUpgrade: audioUpgrade,
            videoUpgrade: videoUpgrade,
            callBubble: callBubble,
            pickMedia: pickMedia,
            unreadMessageIndicator: unreadMessageIndicator,
            operatorTypingIndicator: operatorTypingIndicator,
            accessibility: accessibility,
            secureTranscriptTitle: secureTranscriptTitle,
            secureTranscriptHeader: secureTranscriptHeader,
            unreadMessageDivider: unreadMessageDivider,
            systemMessageStyle: systemMessage.toNewSystemMessageStyle(),
            gliaVirtualAssistant: gliaVirtualAssistant
        )
    }
}
