import UIKit

extension Theme.OperatorMessageStyle {
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

        fileDownload.apply(
            configuration: configuration?.file,
            assetsBuilder: assetsBuilder
        )
        operatorImage.apply(configuration: configuration?.userImage)
    }
}
