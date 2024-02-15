import UIKit

extension ConnectStyle {
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
