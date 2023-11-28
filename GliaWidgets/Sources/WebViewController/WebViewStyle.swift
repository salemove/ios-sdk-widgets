import UIKit

public struct WebViewStyle {
    /// Style of the view's header (navigation bar area).
    public var header: HeaderStyle

    ///
    /// - Parameter header: Style of the view's header (navigation bar area).
    public init(header: HeaderStyle) {
        self.header = header
    }

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
