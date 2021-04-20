import UIKit

/// Style of the message entry area.
public struct ChatMessageEntryStyle {
    /// Font of the message text.
    public var messageFont: UIFont

    /// Color of the message text.
    public var messageColor: UIColor

    /// Placeholder text of the message text view.
    public var placeholder: String

    /// Font of the placeholder text used when a choice card is awaiting for the answer.
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

    ///
    /// - Parameters:
    ///   - messageFont: Font of the message text.
    ///   - messageColor: Color of the message text.
    ///   - placeholder: Placeholder text of the message text view.
    ///   - choiceCardPlaceholder: Font of the placeholder text used when a choice card is awaiting for the answer.
    ///   - placeholderFont: Font of the placeholder text.
    ///   - placeholderColor: Color of the placeholder text.
    ///   - separatorColor: Color of the separator line.
    ///   - backgroundColor: Background color of the view.
    ///   - mediaButton: Style of the media attachment button.
    ///   - sendButton: Style of the send button.
    ///   - uploadList: Style of the media upload menu popover.
    ///
    public init(messageFont: UIFont,
                messageColor: UIColor,
                placeholder: String,
                choiceCardPlaceholder: String,
                placeholderFont: UIFont,
                placeholderColor: UIColor,
                separatorColor: UIColor,
                backgroundColor: UIColor,
                mediaButton: MessageButtonStyle,
                sendButton: MessageButtonStyle,
                uploadList: FileUploadListStyle) {
        self.messageFont = messageFont
        self.messageColor = messageColor
        self.placeholder = placeholder
        self.choiceCardPlaceholder = choiceCardPlaceholder
        self.placeholderFont = placeholderFont
        self.placeholderColor = placeholderColor
        self.separatorColor = separatorColor
        self.backgroundColor = backgroundColor
        self.mediaButton = mediaButton
        self.sendButton = sendButton
        self.uploadList = uploadList
    }
}
