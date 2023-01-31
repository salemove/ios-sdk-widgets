import UIKit

/// Style of a view that shows the engagement connection state - enqueued, connecting or connected. This view consists of an operator image with an animation of several concentric circles extending from it and two status labels below it.
public struct ConnectStyle {
    /// Style of the operator view.
    public var connectOperator: ConnectOperatorStyle

    /// Style of the in-queue state. The view in this state will be shown to the visitor when they have requested an engagement and are waiting in a queue to be connected to an operator.
    public var queue: ConnectStatusStyle

    /// Style of the connecting state. The view in this state will be shown to the visitor when the operator has picked up the engagement but is still connecting to the visitor.
    public var connecting: ConnectStatusStyle

    /// Style of the connected state. The view in this state will be shown to the visitor when the operator has picked up the engagement and is successfully connected to the visitor.
    public var connected: ConnectStatusStyle

    /// Style of the transferring state. The view in this state will be shown to the visitor when the operator has started a operator-to-queue engagement transfer for the visitor.
    public var transferring: ConnectStatusStyle

    /// Style of the onHold state. The view in this state will be shown to the visitor when the operator has successfully connected to the visitor and has put visitor on hold.
    public var onHold: ConnectStatusStyle

    ///
    /// - Parameters:
    ///   - queueOperator: Style of the operator view.
    ///   - queue: Style of the in-queue state. The view in this state will be shown to the visitor when they have requested an engagement and are waiting in a queue to be connected to an operator.
    ///   - connecting: Style of the connecting state. The view in this state will be shown to the visitor when the operator has picked up the engagement but is still connecting to the visitor.
    ///   - connected: Style of the connected state. The view in this state will be shown to the visitor when the operator has picked up the engagement and is successfully connected to the visitor.
    ///   - transferring: Style of the transferring state. The view in this state will be shown to the visitor when the operator has started a operator-to-queue engagement transfer for the visitor.
    ///   - onHold: Style of the onHold state. The view in this state will be shown to the visitor when the operator has successfully connected to the visitor and has put visitor on hold.
    ///
    public init(
        queueOperator: ConnectOperatorStyle,
        queue: ConnectStatusStyle,
        connecting: ConnectStatusStyle,
        connected: ConnectStatusStyle,
        transferring: ConnectStatusStyle,
        onHold: ConnectStatusStyle
    ) {
        self.connectOperator = queueOperator
        self.queue = queue
        self.connecting = connecting
        self.connected = connected
        self.transferring = transferring
        self.onHold = onHold
    }

    mutating func apply(
        configuration: RemoteConfiguration.EngagementStates?,
        assetsBuilder: RemoteConfiguration.AssetsBuilder
    ) {
        connectOperator.apply(configuration: configuration?.operator)
        queue.apply(
            configuration: configuration?.queue,
            assetsBuilder: assetsBuilder
        )
        connecting.apply(
            configuration: configuration?.connecting,
            assetsBuilder: assetsBuilder
        )
        connected.apply(
            configuration: configuration?.connected,
            assetsBuilder: assetsBuilder
        )
        transferring.apply(
            configuration: configuration?.transferring,
            assetsBuilder: assetsBuilder
        )
        onHold.apply(
            configuration: configuration?.onHold,
            assetsBuilder: assetsBuilder
        )
    }
}
