import UIKit

public struct ChatMessageEntryStyle {
    public var messageFont: UIFont
    public var messageColor: UIColor
    public var placeholder: String
    public var placeholderFont: UIFont
    public var placeholderColor: UIColor
    public var sendButtonColor: UIColor
    public var separatorColor: UIColor
    public var backgroundColor: UIColor

    public init(messageFont: UIFont,
                messageColor: UIColor,
                placeholder: String,
                placeholderFont: UIFont,
                placeholderColor: UIColor,
                sendButtonColor: UIColor,
                separatorColor: UIColor,
                backgroundColor: UIColor) {
        self.messageFont = messageFont
        self.messageColor = messageColor
        self.placeholder = placeholder
        self.placeholderFont = placeholderFont
        self.placeholderColor = placeholderColor
        self.sendButtonColor = sendButtonColor
        self.separatorColor = separatorColor
        self.backgroundColor = backgroundColor
    }
}
