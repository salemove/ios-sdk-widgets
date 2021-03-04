import UIKit

public struct ChatMessageEntryStyle {
    public var messageFont: UIFont
    public var messageColor: UIColor
    public var placeholder: String
    public var placeholderFont: UIFont
    public var placeholderColor: UIColor
    public var separatorColor: UIColor
    public var backgroundColor: UIColor
    public var mediaButton: MessageButtonStyle
    public var sendButton: MessageButtonStyle
    public var uploadList: FileUploadListStyle

    public init(messageFont: UIFont,
                messageColor: UIColor,
                placeholder: String,
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
        self.placeholderFont = placeholderFont
        self.placeholderColor = placeholderColor
        self.separatorColor = separatorColor
        self.backgroundColor = backgroundColor
        self.mediaButton = mediaButton
        self.sendButton = sendButton
        self.uploadList = uploadList
    }
}
