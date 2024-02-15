import UIKit

extension Theme.VisitorMessageStyle {
    mutating func apply(
        configuration: RemoteConfiguration.MessageBalloon?,
        assetsBuilder: RemoteConfiguration.AssetsBuilder
    ) {
        background.apply(configuration: configuration?.background)

        configuration?.background?.color?.value
            .map { UIColor(hex: $0) }
            .first
            .unwrap { imageFile.backgroundColor = $0 }

        text.apply(
            configuration: configuration?.text,
            assetsBuilder: assetsBuilder
        )
        status.apply(
            configuration: configuration?.status,
            assetsBuilder: assetsBuilder
        )

        fileDownload.apply(
            configuration: configuration?.file,
            assetsBuilder: assetsBuilder
        )
    }
}
