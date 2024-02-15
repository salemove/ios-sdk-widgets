import UIKit

extension WebViewStyle {
    mutating func apply(
        configuration: RemoteConfiguration.WebView?,
        assetsBuilder: RemoteConfiguration.AssetsBuilder
    ) {
        header.apply(
            configuration: configuration?.header,
            assetsBuilder: assetsBuilder
        )
    }
}
