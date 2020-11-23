import UIKit

public struct ChatStyle {
    public var header: HeaderStyle
    public var sentMessage: SentChatMessageStyle
    public var receivedMessage: ReceivedChatMessageStyle
    public var backgroundColor: UIColor

    public init(header: HeaderStyle,
                sentMessage: SentChatMessageStyle,
                receivedMessage: ReceivedChatMessageStyle,
                backgroundColor: UIColor) {
        self.header = header
        self.sentMessage = sentMessage
        self.receivedMessage = receivedMessage
        self.backgroundColor = backgroundColor
    }
}
