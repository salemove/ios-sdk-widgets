import UIKit

public struct QueueStyle {
    public var queueOperator: QueueOperatorStyle
    public var enqueued: QueueStatusStyle
    public var connecting: QueueStatusStyle
    public var connected: QueueStatusStyle

    public init(queueOperator: QueueOperatorStyle,
                enqueued: QueueStatusStyle,
                connecting: QueueStatusStyle,
                connected: QueueStatusStyle) {
        self.queueOperator = queueOperator
        self.enqueued = enqueued
        self.connecting = connecting
        self.connected = connected
    }
}
