import UIKit

public struct Theme {
    public var primaryColor: UIColor {
        didSet {
            chatStyle.primaryColor = primaryColor
        }
    }
    public var chatStyle: ChatStyle

    public init() {
        primaryColor = Color.primary
        chatStyle = ChatStyle(primaryColor: primaryColor)
    }
}
