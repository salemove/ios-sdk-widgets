import UIKit

extension SecureConversations.WelcomeStyle.SendButtonStyle {
    mutating func apply(
        enabled: RemoteConfiguration.Button?,
        disabled: RemoteConfiguration.Button?,
        loading: RemoteConfiguration.Button?,
        activityIndicatorColor: RemoteConfiguration.Color?,
        assetBuilder: RemoteConfiguration.AssetsBuilder
    ) {
        enabledStyle.apply(
            configuration: enabled,
            assetBuilder: assetBuilder
        )
        disabledStyle.apply(
            configuration: disabled,
            assetBuilder: assetBuilder
        )
        loadingStyle.apply(
            configuration: loading,
            activityIndicatorColor: activityIndicatorColor,
            assetBuilder: assetBuilder
        )
    }
}
