import UIKit

public struct HeaderStyle {
    public var backgroundColor: UIColor
    public var title: String
    public var titleFont: UIFont
    public var titleFontColor: UIColor
    public var backButtonColor: UIColor

    public init(backgroundColor: UIColor,
                title: String,
                titleFont: UIFont,
                titleFontColor: UIColor,
                backButtonColor: UIColor) {
        self.backgroundColor = backgroundColor
        self.title = title
        self.titleFont = titleFont
        self.titleFontColor = titleFontColor
        self.backButtonColor = backButtonColor
    }
}
