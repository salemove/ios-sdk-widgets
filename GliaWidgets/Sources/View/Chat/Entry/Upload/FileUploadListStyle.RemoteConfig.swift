import Foundation

extension FileUploadListStyle {
    func apply(
        configuration: RemoteConfiguration.FileUploadBar?,
        disabledConfiguration: RemoteConfiguration.FileUploadBar?,
        assetsBuilder: RemoteConfiguration.AssetsBuilder
    ) {
        item.apply(
            configuration: configuration,
            disabledConfiguration: disabledConfiguration,
            assetsBuilder: assetsBuilder
        )
    }
}
