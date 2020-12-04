import UIKit

public struct AlertStyle {
    public var titleFont: UIFont
    public var titleColor: UIColor
    public var messageFont: UIFont
    public var messageColor: UIColor
    public var backgroundColor: UIColor
    public var closeButtonColor: UIColor
    public var positiveAction: AlertActionButtonStyle
    public var negativeAction: AlertActionButtonStyle
    public var yesActionTitle: String
    public var noActionTitle: String

    public init(titleFont: UIFont,
                titleColor: UIColor,
                messageFont: UIFont,
                messageColor: UIColor,
                backgroundColor: UIColor,
                closeButtonColor: UIColor,
                positiveAction: AlertActionButtonStyle,
                negativeAction: AlertActionButtonStyle,
                yesActionTitle: String,
                noActionTitle: String) {
        self.titleFont = titleFont
        self.titleColor = titleColor
        self.messageFont = messageFont
        self.messageColor = messageColor
        self.backgroundColor = backgroundColor
        self.closeButtonColor = closeButtonColor
        self.positiveAction = positiveAction
        self.negativeAction = negativeAction
        self.yesActionTitle = yesActionTitle
        self.noActionTitle = noActionTitle
    }
}
