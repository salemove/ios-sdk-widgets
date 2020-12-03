import UIKit

public struct AlertButtonStyle {
    public var titleFont: UIFont
    public var titleColor: UIColor
    public var backgroundColor: UIColor

    public init(titleFont: UIFont,
                titleColor: UIColor,
                backgroundColor: UIColor) {
        self.titleFont = titleFont
        self.titleColor = titleColor
        self.backgroundColor = backgroundColor
    }
}
