import UIKit

/// Style of the GVA Quick Reply Button
public struct GvaQuickReplyButtonStyle {
    /// Font of the button
    public var textFont: UIFont

    /// Color of the button
    public var textColor: UIColor

    /// Text style of the button
    public var textStyle: UIFont.TextStyle

    /// Background of the button
    public var backgroundColor: ColorType

    /// Corner radius of the button
    public var cornerRadius: CGFloat

    /// Border color of the button
    public var borderColor: UIColor

    /// Border width of the button
    public var borderWidth: CGFloat

    init(
        textFont: UIFont,
        textColor: UIColor,
        textStyle: UIFont.TextStyle = .title2,
        backgroundColor: ColorType,
        cornerRadius: CGFloat,
        borderColor: UIColor,
        borderWidth: CGFloat
    ) {
        self.textFont = textFont
        self.textColor = textColor
        self.textStyle = textStyle
        self.backgroundColor = backgroundColor
        self.cornerRadius = cornerRadius
        self.borderColor = borderColor
        self.borderWidth = borderWidth
    }
}
