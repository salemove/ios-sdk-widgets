import UIKit

public struct BadgeStyle {
    public var font: UIFont
    public var fontColor: UIColor
    public var backgroundColor: UIColor

    public init(font: UIFont,
                fontColor: UIColor,
                backgroundColor: UIColor) {
        self.font = font
        self.fontColor = fontColor
        self.backgroundColor = backgroundColor
    }
}
