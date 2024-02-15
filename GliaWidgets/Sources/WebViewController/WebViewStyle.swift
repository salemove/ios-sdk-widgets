import UIKit

public struct WebViewStyle {
    /// Style of the view's header (navigation bar area).
    public var header: HeaderStyle

    /// - Parameters:
    ///   - header: Style of the view's header (navigation bar area).
    ///
    public init(header: HeaderStyle) {
        self.header = header
    }
}
