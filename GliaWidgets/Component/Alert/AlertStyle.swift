import UIKit

public struct AlertStyle {
    public var title: String?
    public var titleFont: UIFont
    public var titleColor: UIColor
    public var backgroundColor: UIColor
    public var positiveButton: AlertButtonStyle
    public var negativeButton: AlertButtonStyle

    public init(title: String?,
                titleFont: UIFont,
                titleColor: UIColor,
                backgroundColor: UIColor,
                positiveButton: AlertButtonStyle,
                negativeButton: AlertButtonStyle) {
        self.title = title
        self.titleFont = titleFont
        self.titleColor = titleColor
        self.backgroundColor = backgroundColor
        self.positiveButton = positiveButton
        self.negativeButton = negativeButton
    }
}
