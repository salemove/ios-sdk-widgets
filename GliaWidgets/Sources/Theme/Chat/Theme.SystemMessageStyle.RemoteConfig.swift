import UIKit

extension Theme.SystemMessageStyle {
    mutating func apply(
        configuration: RemoteConfiguration.MessageBalloon?,
        assetsBuilder: RemoteConfiguration.AssetsBuilder
    ) {
        background.apply(configuration: configuration?.background)
        text.apply(
            configuration: configuration?.text,
            assetsBuilder: assetsBuilder
        )
        fileDownload.apply(
            configuration: configuration?.file,
            assetsBuilder: assetsBuilder
        )
        configuration?.background?.color?.value
            .map { UIColor(hex: $0) }
            .first
            .unwrap { imageFile.backgroundColor = $0 }
    }
}
