import UIKit

public struct HeaderStyle {
    public var titleFont: UIFont
    public var titleColor: UIColor
    public var leftItemColor: UIColor
    public var rightItemColor: UIColor
    public var backgroundColor: UIColor

    public init(titleFont: UIFont,
                titleColor: UIColor,
                leftItemColor: UIColor,
                rightItemColor: UIColor,
                backgroundColor: UIColor) {
        self.titleFont = titleFont
        self.titleColor = titleColor
        self.leftItemColor = leftItemColor
        self.rightItemColor = rightItemColor
        self.backgroundColor = backgroundColor
    }
}
