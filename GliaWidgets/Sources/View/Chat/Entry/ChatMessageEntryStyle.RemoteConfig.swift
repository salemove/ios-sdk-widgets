import UIKit

extension ChatMessageEntryStyle {
    mutating func apply(
        configuration: RemoteConfiguration.Input?,
        disabledConfiguration: RemoteConfiguration.Input?,
        assetsBuilder: RemoteConfiguration.AssetsBuilder
    ) {
        enabled.apply(
            configuration: configuration,
            disabledConfiguration: disabledConfiguration,
            assetsBuilder: assetsBuilder
        )
        disabled.apply(
            configuration: configuration,
            disabledConfiguration: disabledConfiguration,
            assetsBuilder: assetsBuilder
        )
    }
}
