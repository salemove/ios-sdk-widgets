import UIKit

public struct HeaderStyle {
    public var title: String?
    public var titleFont: UIFont
    public var titleColor: UIColor
    public var leftItemColor: UIColor
    public var rightItemColor: UIColor
    public var backgroundColor: UIColor
    public var preferredStatusBarStyle: UIStatusBarStyle

    public init(title: String?,
                titleFont: UIFont,
                titleColor: UIColor,
                leftItemColor: UIColor,
                rightItemColor: UIColor,
                backgroundColor: UIColor,
                preferredStatusBarStyle: UIStatusBarStyle) {
        self.title = title
        self.titleFont = titleFont
        self.titleColor = titleColor
        self.leftItemColor = leftItemColor
        self.rightItemColor = rightItemColor
        self.backgroundColor = backgroundColor
        self.preferredStatusBarStyle = preferredStatusBarStyle
    }
}
