import UIKit

extension CallButtonBarStyle {
    /// Applies remote configuration to the button bar.
    mutating func applyBarConfiguration(
        _ bar: RemoteConfiguration.ButtonBar?,
        assetsBuilder: RemoteConfiguration.AssetsBuilder
    ) {
        minimizeButton.applyBarButtonConfig(
            button: bar?.minimizeButton,
            assetsBuilder: assetsBuilder
        )
        chatButton.applyBarButtonConfig(
            button: bar?.chatButton,
            assetsBuilder: assetsBuilder
        )
        videoButton.applyBarButtonConfig(
            button: bar?.videoButton,
            assetsBuilder: assetsBuilder
        )
        muteButton.applyBarButtonConfig(
            button: bar?.muteButton,
            assetsBuilder: assetsBuilder
        )
        speakerButton.applyBarButtonConfig(
            button: bar?.speakerButton,
            assetsBuilder: assetsBuilder
        )
        badge.apply(
            configuration: bar?.badge,
            assetsBuilder: assetsBuilder
        )
    }
}
