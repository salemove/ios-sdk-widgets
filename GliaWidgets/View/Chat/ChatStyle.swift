import UIKit

public struct ChatStyle {
    public var header: HeaderStyle
    public var queue: QueueStyle
    public var visitorMessage: ChatMessageStyle
    public var operatorMessage: ChatMessageStyle
    public var backgroundColor: UIColor
    public var endButton: ActionButtonStyle
    public var messageEntry: ChatMessageEntryStyle

    public init(header: HeaderStyle,
                queue: QueueStyle,
                visitorMessage: ChatMessageStyle,
                operatorMessage: ChatMessageStyle,
                backgroundColor: UIColor,
                endButton: ActionButtonStyle,
                messageEntry: ChatMessageEntryStyle) {
        self.header = header
        self.queue = queue
        self.visitorMessage = visitorMessage
        self.operatorMessage = operatorMessage
        self.backgroundColor = backgroundColor
        self.endButton = endButton
        self.messageEntry = messageEntry
    }
}
