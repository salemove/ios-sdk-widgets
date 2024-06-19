import UIKit

func unavailable(function: StaticString = #function) -> Never {
    fatalError("This implementation for \(function) is not longer available.")
}

extension ChatStyle {
    /// Unavailable. Style of the message sent by the operator.
    @available(*, unavailable, message: "Unavailable, use ``ChatStyle.operatorMessageStyle`` instead.")
    public var operatorMessage: OperatorChatMessageStyle {
        unavailable()
    }

    /// Unavailable. Style of the system message
    @available(*, unavailable, message: "Unavailable, use ``ChatStyle.systemMessageStyle`` instead.")
    public var systemMessage: SystemMessageStyle {
        unavailable()
    }

    /// Unavailable. Style of the message sent by the visitor.
    @available(*, unavailable, message: "Unavailable, use ``ChatStyle.visitorMessageStyle`` instead.")
    public var visitorMessage: VisitorChatMessageStyle {
        unavailable()
    }

    /// Unavailable. Style of the choice card sent to the visitor by the AI engine.
    @available(*, unavailable, message: "Unavailable, use ``ChatStyle.choiceCardStyle`` instead.")
    public var choiceCard: ChoiceCardStyle {
        unavailable()
    }

    /// Unavailable.
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
    @available(*, unavailable, message: "Unavailable, use designated initializer instead.")
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
        unavailable()
    }
}

/// Unavailable. Style of the choice card sent to the visitor by the AI engine.
@available(*, unavailable, message: "Unavailable, use ``Theme.ChoiceCardStyle`` instead.")
public final class ChoiceCardStyle: OperatorChatMessageStyle {
    /// Color of the choice card's border.
    public var frameColor: UIColor

    /// Width of the choice card's border.
    public var borderWidth: CGFloat

    /// Corner radius of the choice card.
    public var cornerRadius: CGFloat

    /// Background color of t the choice card.
    public var backgroundColor: UIColor

    /// Styles of the choice card's answer options.
    public var choiceOption: ChoiceCardOptionStyle

    /// Accessibility related properties.
    public var accessibility: Accessibility

    ///
    /// - Parameters:
    ///   - mainText: Style of the choice card's main text.
    ///   - frameColor: Color of the choice card's border.
    ///   - imageFile: Style of a choice card's image.
    ///   - fileDownload: Style of a choice card's attached files.
    ///   - operatorImage: Style of the operator's image to the left of a choice card.
    ///   - choiceOption: Styles of the choice card's answer options.
    ///   - accessibility: Accessibility related properties.
    public init(
        mainText: ChatTextContentStyle,
        frameColor: UIColor,
        borderWidth: CGFloat = 1,
        cornerRadius: CGFloat = 8,
        backgroundColor: UIColor,
        imageFile: ChatImageFileContentStyle,
        fileDownload: ChatFileDownloadStyle,
        operatorImage: UserImageStyle,
        choiceOption: ChoiceCardOptionStyle,
        accessibility: Accessibility
    ) {
        unavailable()
    }

    /// Accessibility properties for ChoiceCardStyle.
    public struct Accessibility: Equatable {
        /// Accessibility label for image.
        public var imageLabel: String

        ///
        /// - Parameter imageLabel: Accessibility label for image.
        public init(imageLabel: String) {
            unavailable()
        }

        /// Accessibility is not supported intentionally.
        public static let unsupported = Self(imageLabel: "")
    }
}

/// Unavailable. Base style of a chat message.
@available(*, unavailable, message: """
Unavailable, use
``Theme.VisitorMessageStyle``,
``Theme.OperatorMessageStyle`` and
``Theme.SystemMessageStyle`` instead.
""")
public class ChatMessageStyle {
    /// Style of the text content.
    public var text: ChatTextContentStyle

    /// Style of the image content.
    public var imageFile: ChatImageFileContentStyle

    /// Style of the downloadable file content.
    public var fileDownload: ChatFileDownloadStyle

    /// - Parameters:
    ///   - text: Style of the text content.
    ///   - imageFile: Style of the image content.
    ///   - fileDownload: Style of the downloadable file content.
    ///
    public init(
        text: ChatTextContentStyle,
        imageFile: ChatImageFileContentStyle,
        fileDownload: ChatFileDownloadStyle
    ) {
        unavailable()
    }
}

/// Unavailable. Style of a visitor's message.
@available(*, unavailable, message: "Unavailable, use ``Theme.VisitorMessageStyle`` instead.")
public class VisitorChatMessageStyle: ChatMessageStyle {
    /// Font of the message status text.
    public var statusFont: UIFont

    /// Color of the message status text.
    public var statusColor: UIColor

    /// Text style of the message status text.
    public var statusTextStyle: UIFont.TextStyle

    /// Text of the message delivered status.
    public var delivered: String

    /// Accessibility related properties.
    public var accessibility: Accessibility

    ///
    /// - Parameters:
    ///   - text: Style of the text content.
    ///   - imageFile: Style of the image content.
    ///   - fileDownload: Style of the downloadable file content.
    ///   - statusFont: Font of the message status text.
    ///   - statusColor: Color of the message status text.
    ///   - statusTextStyle: Text style of the message status text.
    ///   - delivered: Text of the message delivered status.
    ///   - accessibility: Accessibility related properties.
    ///
    public init(
        text: ChatTextContentStyle,
        imageFile: ChatImageFileContentStyle,
        fileDownload: ChatFileDownloadStyle,
        statusFont: UIFont,
        statusColor: UIColor,
        statusTextStyle: UIFont.TextStyle,
        delivered: String,
        accessibility: Accessibility = .unsupported
    ) {
        unavailable()
    }

    /// Accessibility properties for VisitorChatMessageStyle.
    public struct Accessibility: Equatable {
        /// Flag that provides font dynamic type by setting `adjustsFontForContentSizeCategory` for component that supports it.
        public var isFontScalingEnabled: Bool

        ///
        /// - Parameter isFontScalingEnabled: Flag that provides font dynamic type by setting `adjustsFontForContentSizeCategory` for component that supports it.
        public init(isFontScalingEnabled: Bool) {
            unavailable()
        }

        /// Accessibility is not supported intentionally.
        public static let unsupported = Self(isFontScalingEnabled: false)
    }
}

/// Unavailable. Style of an operator's message.
@available(*, unavailable, message: "Unavailable, use ``Theme.OperatorMessageStyle`` instead.")
public class OperatorChatMessageStyle: ChatMessageStyle {
    /// Style of the operator's image.
    public var operatorImage: UserImageStyle

    ///
    /// - Parameters:
    ///   - text: Style of the text content.
    ///   - imageFile: Style of the image content.
    ///   - fileDownload: Style of the downloadable file content.
    ///   - operatorImage: Style of the operator's image.
    ///
    public init(
        text: ChatTextContentStyle,
        imageFile: ChatImageFileContentStyle,
        fileDownload: ChatFileDownloadStyle,
        operatorImage: UserImageStyle
    ) {
        unavailable()
    }
}

/// Unavailable. Style of a system message.
@available(*, unavailable, message: "Unavailable, use ``Theme.SystemMessageStyle`` instead.")
final public class SystemMessageStyle: ChatMessageStyle {
    /// - Parameters:
    ///   - text: Style of the text content.
    ///   - imageFile: Style of the image content.
    ///   - fileDownload: Style of the downloadable file content.
    override public init(
        text: ChatTextContentStyle,
        imageFile: ChatImageFileContentStyle,
        fileDownload: ChatFileDownloadStyle
    ) {
        unavailable()
    }
}
