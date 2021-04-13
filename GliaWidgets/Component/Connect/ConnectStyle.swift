import UIKit

public struct ConnectStyle {
    public var connectOperator: ConnectOperatorStyle
    public var queue: ConnectStatusStyle
    public var connecting: ConnectStatusStyle
    public var connected: ConnectStatusStyle

    public init(queueOperator: ConnectOperatorStyle,
                queue: ConnectStatusStyle,
                connecting: ConnectStatusStyle,
                connected: ConnectStatusStyle) {
        self.connectOperator = queueOperator
        self.queue = queue
        self.connecting = connecting
        self.connected = connected
    }
}
