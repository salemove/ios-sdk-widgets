import UIKit

extension EntryWidgetStyle.MediaTypeItemsStyle {
    mutating func apply(
        configuration: RemoteConfiguration.MediaTypeItems?,
        assetBuilder: RemoteConfiguration.AssetsBuilder
    ) {
        mediaItemStyle.apply(configuration: configuration?.mediaTypeItem, assetsBuilder: assetBuilder)

        configuration?.dividerColor?.value
            .map { UIColor(hex: $0) }
            .first
            .unwrap { dividerColor = $0 }
    }
}
