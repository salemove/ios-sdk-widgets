import UIKit

public struct AlertStyle {
    public var titleFont: UIFont
    public var titleColor: UIColor
    public var messageFont: UIFont
    public var messageColor: UIColor
    public var backgroundColor: UIColor
    public var positiveButton: AlertButtonStyle
    public var negativeButton: AlertButtonStyle

    public init(titleFont: UIFont,
                titleColor: UIColor,
                messageFont: UIFont,
                messageColor: UIColor,
                backgroundColor: UIColor,
                positiveButton: AlertButtonStyle,
                negativeButton: AlertButtonStyle) {
        self.titleFont = titleFont
        self.titleColor = titleColor
        self.messageFont = messageFont
        self.messageColor = messageColor
        self.backgroundColor = backgroundColor
        self.positiveButton = positiveButton
        self.negativeButton = negativeButton
    }
}
