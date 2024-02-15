import Foundation

extension GvaGalleryListViewStyle {
    mutating func apply(
        configuration: RemoteConfiguration.GvaGalleryCards?,
        assetBuilder: RemoteConfiguration.AssetsBuilder
    ) {
        operatorImage.apply(configuration: configuration?.operatorImage)
        cardStyle.apply(
            configuration: configuration?.cardStyle,
            assetBuilder: assetBuilder
        )
    }
}
