import UIKit

public class ChatStyle: EngagementStyle {
    public var visitorMessage: VisitorChatMessageStyle
    public var operatorMessage: OperatorChatMessageStyle
    public var messageEntry: ChatMessageEntryStyle

    public init(header: HeaderStyle,
                queue: QueueStyle,
                visitorMessage: VisitorChatMessageStyle,
                operatorMessage: OperatorChatMessageStyle,
                backgroundColor: UIColor,
                endButton: ActionButtonStyle,
                messageEntry: ChatMessageEntryStyle,
                preferredStatusBarStyle: UIStatusBarStyle) {
        self.visitorMessage = visitorMessage
        self.operatorMessage = operatorMessage
        self.messageEntry = messageEntry
        super.init(header: header,
                   queue: queue,
                   backgroundColor: backgroundColor,
                   endButton: endButton,
                   preferredStatusBarStyle: preferredStatusBarStyle)
    }
}
