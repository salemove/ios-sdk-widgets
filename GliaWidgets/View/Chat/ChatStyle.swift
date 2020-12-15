import UIKit

public struct ChatStyle {
    public var header: HeaderStyle
    public var queue: QueueStyle
    public var sentMessage: ChatMessageStyle
    public var receivedMessage: ChatMessageStyle
    public var backgroundColor: UIColor
    public var endButton: ActionButtonStyle
    public var messageEntry: ChatMessageEntryStyle

    public init(header: HeaderStyle,
                queue: QueueStyle,
                sentMessage: ChatMessageStyle,
                receivedMessage: ChatMessageStyle,
                backgroundColor: UIColor,
                endButton: ActionButtonStyle,
                messageEntry: ChatMessageEntryStyle) {
        self.header = header
        self.queue = queue
        self.sentMessage = sentMessage
        self.receivedMessage = receivedMessage
        self.backgroundColor = backgroundColor
        self.endButton = endButton
        self.messageEntry = messageEntry
    }
}
