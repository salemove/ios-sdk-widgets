import Foundation

extension FileUploadListStyle {
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
