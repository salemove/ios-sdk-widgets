import UIKit

public struct ChatStyle {
    public var headerStyle: HeaderStyle
    public var backgroundColor: UIColor

    public init(headerStyle: HeaderStyle,
                backgroundColor: UIColor) {
        self.headerStyle = headerStyle
        self.backgroundColor = backgroundColor
    }
}
