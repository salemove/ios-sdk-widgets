import UIKit

extension BubbleStyle {
    /// Applies remote configuration to the bubble.
    func apply(
        configuration: RemoteConfiguration.Bubble?,
        assetsBuilder: RemoteConfiguration.AssetsBuilder
    ) {
        onHoldOverlay.apply(configuration: configuration?.onHoldOverlay)
        badge?.apply(
            configuration: configuration?.badge,
            assetsBuilder: assetsBuilder
        )
        userImage.apply(configuration: configuration?.userImage)
    }
}
