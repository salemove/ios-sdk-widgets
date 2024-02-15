import UIKit

extension GvaGalleryCardStyle.ButtonStyle {
    mutating func apply(
        configuration: RemoteConfiguration.Button?,
        assetBuilder: RemoteConfiguration.AssetsBuilder
    ) {
        title.apply(
            configuration: configuration?.text,
            assetBuilder: assetBuilder
        )
        background.apply(configuration: configuration?.background)
    }
}
