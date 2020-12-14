import UIKit

public struct AlertStyle {
    public var titleFont: UIFont
    public var titleColor: UIColor
    public var messageFont: UIFont
    public var messageColor: UIColor
    public var backgroundColor: UIColor
    public var closeButtonColor: UIColor
    public var positiveAction: ActionButtonStyle
    public var negativeAction: ActionButtonStyle

    public init(titleFont: UIFont,
                titleColor: UIColor,
                messageFont: UIFont,
                messageColor: UIColor,
                backgroundColor: UIColor,
                closeButtonColor: UIColor,
                positiveAction: ActionButtonStyle,
                negativeAction: ActionButtonStyle) {
        self.titleFont = titleFont
        self.titleColor = titleColor
        self.messageFont = messageFont
        self.messageColor = messageColor
        self.backgroundColor = backgroundColor
        self.closeButtonColor = closeButtonColor
        self.positiveAction = positiveAction
        self.negativeAction = negativeAction
    }
}
