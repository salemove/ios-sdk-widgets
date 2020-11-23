import UIKit

public struct ReceivedChatMessageStyle {
    public var messageFont: UIFont
    public var messageColor: UIColor
    public var backgroundColor: UIColor

    public init(messageFont: UIFont,
                messageColor: UIColor,
                backgroundColor: UIColor) {
        self.messageFont = messageFont
        self.messageColor = messageColor
        self.backgroundColor = backgroundColor
    }
}
