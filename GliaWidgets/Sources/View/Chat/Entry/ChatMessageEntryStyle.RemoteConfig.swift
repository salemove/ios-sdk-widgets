import UIKit

extension ChatMessageEntryStyle {
    mutating func apply(
        configuration: RemoteConfiguration.Input?,
        disabledConfiguration: RemoteConfiguration.Input?,
        assetsBuilder: RemoteConfiguration.AssetsBuilder
    ) {
        enabled.apply(configuration: configuration, assetsBuilder: assetsBuilder)
        // TODO: Add Unified customization (MOB-3762)
    }
}
