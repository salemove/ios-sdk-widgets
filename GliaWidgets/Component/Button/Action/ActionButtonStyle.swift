import UIKit

public struct ActionButtonStyle {
    public var title: String
    public var titleFont: UIFont
    public var titleColor: UIColor
    public var backgroundColor: UIColor

    public init(title: String,
                titleFont: UIFont,
                titleColor: UIColor,
                backgroundColor: UIColor) {
        self.title = title
        self.titleFont = titleFont
        self.titleColor = titleColor
        self.backgroundColor = backgroundColor
    }
}
