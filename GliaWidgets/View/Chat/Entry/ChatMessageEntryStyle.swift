import UIKit

/// Style of the message entry area.
public struct ChatMessageEntryStyle {
    /// Font of the message text.
    public var messageFont: UIFont

    /// Color of the message text.
    public var messageColor: UIColor

    /// Text style of the message text.
    public var messageTextStyle: UIFont.TextStyle

    /// Placeholder text of the message input view used when the user is engaged.
    public var enterMessagePlaceholder: String

    /// Placeholder text of the message input view used when user input is required to start engagement.
    public var startEngagementPlaceholder: String

    /// Placeholder text of the message input view used when a choice card is awaiting for the answer.
    public var choiceCardPlaceholder: String

    /// Font of the placeholder text.
    public var placeholderFont: UIFont

    /// Color of the placeholder text.
    public var placeholderColor: UIColor

    /// Text style of the placeholder text.
    public var placeholderTextStyle: UIFont.TextStyle

    /// Color of the separator line.
    public var separatorColor: UIColor

    /// Background color of the view.
    public var backgroundColor: UIColor

    /// Style of the media attachment button.
    public var mediaButton: MessageButtonStyle

    /// Style of the send button.
    public var sendButton: MessageButtonStyle

    /// Style of the media upload menu popover.
    public var uploadList: FileUploadListStyle

    /// Accessibility related properties.
    public var accessibility: Accessibility

    ///
    /// - Parameters:
    ///   - messageFont: Font of the message text.
    ///   - messageColor: Color of the message text.
    ///   - messageTextStyle: Text style of the message text.
    ///   - enterMessagePlaceholder: Placeholder text of the message input view used when the user is engaged.
    ///   - startEngagementPlaceholder:Placeholder text of the message input view used when user input is required to start engagement.
    ///   - choiceCardPlaceholder: Placeholder text of the message input view used when a choice card is awaiting for the answer.
    ///   - placeholderFont: Font of the placeholder text.
    ///   - placeholderColor: Color of the placeholder text.
    ///   - placeholderTextStyle: Text style of the placeholder text.
    ///   - separatorColor: Color of the separator line.
    ///   - backgroundColor: Background color of the view.
    ///   - mediaButton: Style of the media attachment button.
    ///   - sendButton: Style of the send button.
    ///   - uploadList: Style of the media upload menu popover.
    ///   - accessibility: Accessibility related properties.
    ///
    public init(
        messageFont: UIFont,
        messageColor: UIColor,
        messageTextStyle: UIFont.TextStyle = .body,
        enterMessagePlaceholder: String,
        startEngagementPlaceholder: String,
        choiceCardPlaceholder: String,
        placeholderFont: UIFont,
        placeholderColor: UIColor,
        placeholderTextStyle: UIFont.TextStyle = .body,
        separatorColor: UIColor,
        backgroundColor: UIColor,
        mediaButton: MessageButtonStyle,
        sendButton: MessageButtonStyle,
        uploadList: FileUploadListStyle,
        accessibility: Accessibility = .unsupported
    ) {
        self.messageFont = messageFont
        self.messageColor = messageColor
        self.messageTextStyle = messageTextStyle
        self.enterMessagePlaceholder = enterMessagePlaceholder
        self.startEngagementPlaceholder = startEngagementPlaceholder
        self.choiceCardPlaceholder = choiceCardPlaceholder
        self.placeholderFont = placeholderFont
        self.placeholderColor = placeholderColor
        self.placeholderTextStyle = placeholderTextStyle
        self.separatorColor = separatorColor
        self.backgroundColor = backgroundColor
        self.mediaButton = mediaButton
        self.sendButton = sendButton
        self.uploadList = uploadList
        self.accessibility = accessibility
    }

    mutating func apply(configuration: RemoteConfiguration.Input?) {
        configuration?.background?.color?.value
            .map { UIColor(hex: $0) }
            .first
            .unwrap { backgroundColor = $0 }

        configuration?.text?.foreground?.value
            .map { UIColor(hex: $0) }
            .first
            .unwrap { messageColor = $0 }

        UIFont.convertToFont(
            font: configuration?.text?.font,
            textStyle: messageTextStyle
        ).unwrap { messageFont = $0 }

        configuration?.placeholder?.foreground?.value
            .map { UIColor(hex: $0) }
            .first
            .unwrap { placeholderColor = $0 }

        UIFont.convertToFont(
            font: configuration?.placeholder?.font,
            textStyle: placeholderTextStyle
        ).unwrap { placeholderFont = $0 }

        configuration?.separator?.value
            .map { UIColor(hex: $0) }
            .first
            .unwrap { separatorColor = $0 }

        configuration?.mediaButton?.tintColor?.value
            .map { UIColor(hex: $0) }
            .first
            .unwrap { mediaButton.color = $0 }

        configuration?.sendButton?.tintColor?.value
            .map { UIColor(hex: $0) }
            .first
            .unwrap { sendButton.color = $0 }

        uploadList.apply(configuration: configuration?.fileUploadBar)
    }
}
