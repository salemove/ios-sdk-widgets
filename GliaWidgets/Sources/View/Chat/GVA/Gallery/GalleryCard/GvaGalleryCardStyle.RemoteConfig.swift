import Foundation

extension GvaGalleryCardStyle {
    mutating func apply(
        configuration: RemoteConfiguration.GVAGalleryCardStyle?,
        assetBuilder: RemoteConfiguration.AssetsBuilder
    ) {
        cardContainer.apply(configuration: configuration?.cardContainer)
        imageView.apply(configuration: configuration?.imageView)
        button.apply(
            configuration: configuration?.button,
            assetBuilder: assetBuilder
        )
        title.apply(
            configuration: configuration?.title,
            assetBuilder: assetBuilder
        )
        subtitle.apply(
            configuration: configuration?.subtitle,
            assetBuilder: assetBuilder
        )
    }
}
