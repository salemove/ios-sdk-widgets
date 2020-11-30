import UIKit

public struct ChatStyle {
    public var header: HeaderStyle
    public var chatOperator: ChatOperatorStyle
    public var sentMessage: ChatMessageStyle
    public var receivedMessage: ChatMessageStyle
    public var backgroundColor: UIColor

    public init(header: HeaderStyle,
                chatOperator: ChatOperatorStyle,
                sentMessage: ChatMessageStyle,
                receivedMessage: ChatMessageStyle,
                backgroundColor: UIColor) {
        self.header = header
        self.chatOperator = chatOperator
        self.sentMessage = sentMessage
        self.receivedMessage = receivedMessage
        self.backgroundColor = backgroundColor
    }
}
