import UIKit

extension UnreadMessageIndicatorStyle {
    mutating func apply(
        configuration: RemoteConfiguration.UnreadIndicator?,
        assetsBuilder: RemoteConfiguration.AssetsBuilder
    ) {
        badge.apply(
            configuration: configuration?.bubble?.badge,
            assetsBuilder: assetsBuilder
        )
        userImage.apply(configuration: configuration?.bubble?.userImage)
        configuration?.backgroundColor?.value
            .first
            .map { UIColor(hex: $0) }
            .unwrap { indicatorImageTintColor = $0 }
    }
}
