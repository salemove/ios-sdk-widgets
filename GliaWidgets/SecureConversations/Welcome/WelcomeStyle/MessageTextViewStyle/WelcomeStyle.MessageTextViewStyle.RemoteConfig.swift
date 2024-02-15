import UIKit

extension SecureConversations.WelcomeStyle.MessageTextViewStyle {
    mutating func apply(
        normal: RemoteConfiguration.Text?,
        disabled: RemoteConfiguration.Text?,
        active: RemoteConfiguration.Text?,
        layer: RemoteConfiguration.Layer?,
        assetBuilder: RemoteConfiguration.AssetsBuilder
    ) {
        normalStyle.apply(
            configuration: normal,
            layerConfiguration: layer,
            assetBuilder: assetBuilder
        )
        disabledStyle.apply(
            configuration: disabled,
            layerConfiguration: layer,
            assetBuilder: assetBuilder
        )
        activeStyle.apply(
            configuration: active,
            layerConfiguration: layer,
            assetBuilder: assetBuilder
        )
    }
}
