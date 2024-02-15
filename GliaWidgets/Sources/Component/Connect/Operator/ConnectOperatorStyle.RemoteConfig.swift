import UIKit

extension ConnectOperatorStyle {
    mutating func apply(configuration: RemoteConfiguration.Operator?) {
        configuration?.animationColor?.value
            .map { UIColor(hex: $0) }
            .first
            .unwrap { animationColor = $0 }

        operatorImage.apply(configuration: configuration?.image)
        onHoldOverlay.apply(configuration: configuration?.onHoldOverlay)
    }
}
