import Foundation

extension MessageCenterFileUploadListStyle {
    func apply(
        configuration: RemoteConfiguration.FileUploadBar?,
        assetsBuilder: RemoteConfiguration.AssetsBuilder
    ) {
        item.apply(
            configuration: configuration,
            assetsBuilder: assetsBuilder
        )
    }
}
