import UIKit

/// Style of a engagement connect view.
public struct ConnectStyle {
    /// Style of the operator view.
    public var connectOperator: ConnectOperatorStyle

    /// Style of the in-queue state.
    public var queue: ConnectStatusStyle

    /// Style of the connecting state.
    public var connecting: ConnectStatusStyle

    /// Style of the connected state.
    public var connected: ConnectStatusStyle

    ///
    /// - Parameters:
    ///   - queueOperator: Style of the operator view.
    ///   - queue: Style of the in-queue state.
    ///   - connecting: Style of the connecting state.
    ///   - connected: Style of the connected state.
    ///
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
