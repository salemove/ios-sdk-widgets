import Foundation

extension GliaVirtualAssistantStyle {
    mutating func apply(
        configuration: RemoteConfiguration.Gva?,
        assetBuilder: RemoteConfiguration.AssetsBuilder
    ) {
        persistentButton.apply(
            configuration?.persistentButton,
            assetBuilder: assetBuilder
        )
        quickReplyButton.apply(
            configuration?.quickReplyButton,
            assetBuilder: assetBuilder
        )
        galleryList.apply(
            configuration: configuration?.galleryCard,
            assetBuilder: assetBuilder
        )
    }
}
