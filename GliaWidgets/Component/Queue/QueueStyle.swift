import UIKit

public struct QueueStyle {
    public var queueOperator: QueueOperatorStyle
    public var waiting: QueueStatusStyle
    public var connecting: QueueStatusStyle
    public var connected: QueueStatusStyle

    public init(queueOperator: QueueOperatorStyle,
                waiting: QueueStatusStyle,
                connecting: QueueStatusStyle,
                connected: QueueStatusStyle) {
        self.queueOperator = queueOperator
        self.waiting = waiting
        self.connecting = connecting
        self.connected = connected
    }
}
