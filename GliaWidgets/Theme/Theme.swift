import UIKit

public protocol Theme {
    var primaryColor: UIColor { get }
    var chatStyle: ChatStyle { get }
}

public extension Theme {
    var primaryColor: UIColor { Color.primary }
    var chatStyle: ChatStyle { ChatStyle() }
}

public struct DefaultTheme: Theme {
    public init() {}
}
