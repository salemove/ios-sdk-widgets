import UIKit

/// Style of the message entry area.
public struct ChatMessageEntryStyle {
    /// Font of the message text.
    public var messageFont: UIFont

    /// Color of the message text.
    public var messageColor: UIColor

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
    ///   - enterMessagePlaceholder: Placeholder text of the message input view used when the user is engaged.
    ///   - startEngagementPlaceholder:Placeholder text of the message input view used when user input is required to start engagement.
    ///   - choiceCardPlaceholder: Placeholder text of the message input view used when a choice card is awaiting for the answer.
    ///   - placeholderFont: Font of the placeholder text.
    ///   - placeholderColor: Color of the placeholder text.
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
        enterMessagePlaceholder: String,
        startEngagementPlaceholder: String,
        choiceCardPlaceholder: String,
        placeholderFont: UIFont,
        placeholderColor: UIColor,
        separatorColor: UIColor,
        backgroundColor: UIColor,
        mediaButton: MessageButtonStyle,
        sendButton: MessageButtonStyle,
        uploadList: FileUploadListStyle,
        accessibility: Accessibility = .unsupported
    ) {
        self.messageFont = messageFont
        self.messageColor = messageColor
        self.enterMessagePlaceholder = enterMessagePlaceholder
        self.startEngagementPlaceholder = startEngagementPlaceholder
        self.choiceCardPlaceholder = choiceCardPlaceholder
        self.placeholderFont = placeholderFont
        self.placeholderColor = placeholderColor
        self.separatorColor = separatorColor
        self.backgroundColor = backgroundColor
        self.mediaButton = mediaButton
        self.sendButton = sendButton
        self.uploadList = uploadList
        self.accessibility = accessibility
    }
}
