import UIKit

extension SecureConversations.WelcomeStyle.TitleImageStyle {
    mutating func apply(
        configuration: RemoteConfiguration.Color?,
        assetBuilder: RemoteConfiguration.AssetsBuilder
    ) {
        configuration?.value
            .map { UIColor(hex: $0) }
            .first
            .unwrap { color = $0 }
    }
}
