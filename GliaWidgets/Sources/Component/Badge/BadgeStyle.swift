import UIKit

/// Style of a badge view. A badge is used to show unread message count 
/// on the minimized bubble and on the chat button in the call view.
public struct BadgeStyle: Equatable {
    /// Font of the text.
    public var font: UIFont

    /// Color of the text.
    public var fontColor: UIColor

    /// Text style of the text.
    public var textStyle: UIFont.TextStyle

    /// Background color of the view.
    public var backgroundColor: ColorType

    /// Border color of the view.
    public var borderColor: ColorType

    /// Border width of the view.
    public var borderWidth: CGFloat

    /// - Parameters:
    ///   - font: Font of the text.
    ///   - fontColor: Color of the text.
    ///   - textStyle: Text style of the text.
    ///   - backgroundColor: Background color of the view.
    ///   - borderColor: Border color of the view
    ///   - borderWidth: Border width of the view
    ///
    public init(
        font: UIFont,
        fontColor: UIColor,
        textStyle: UIFont.TextStyle = .caption1,
        backgroundColor: ColorType,
        borderColor: ColorType = .fill(color: .clear),
        borderWidth: CGFloat = .zero
    ) {
        self.font = font
        self.fontColor = fontColor
        self.textStyle = textStyle
        self.backgroundColor = backgroundColor
        self.borderColor = borderColor
        self.borderWidth = borderWidth
    }
}
