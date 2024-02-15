import UIKit

public struct NumberSlotStyle: Equatable {
    /// Background color of the view.
    public var backgroundColor: ColorType

    /// Border color of the view.
    public var borderColor: UIColor

    /// Border width of the view.
    public var borderWidth: CGFloat

    /// Corner radius of the view.
    public var cornerRadius: CGFloat

    /// Font of the number.
    public var numberFont: UIFont

    /// Color of the number.
    public var numberColor: UIColor

    /// Style of the number.
    public var numberStyle: UIFont.TextStyle

    /// Accessibility related properties.
    public var accessibility: Accessibility

    /// - Parameters:
    ///   - backgroundColor: Color of the background.
    ///   - borderColor: Border color of the view.
    ///   - borderWidth: Border width of the view.
    ///   - cornerRadius: Corner radius of the view.
    ///   - numberFont: Font of the number.
    ///   - numberColor: Color of the number.
    ///   - numberStyle: Style of the number.
    ///   - accessibility: Accessibility related properties.
    ///
    public init(
        backgroundColor: ColorType,
        borderColor: UIColor,
        borderWidth: CGFloat,
        cornerRadius: CGFloat,
        numberFont: UIFont,
        numberColor: UIColor,
        numberStyle: UIFont.TextStyle = .largeTitle,
        accessibility: Accessibility
    ) {
        self.backgroundColor = backgroundColor
        self.borderColor = borderColor
        self.borderWidth = borderWidth
        self.cornerRadius = cornerRadius
        self.numberFont = numberFont
        self.numberColor = numberColor
        self.numberStyle = numberStyle
        self.accessibility = accessibility
    }
}
