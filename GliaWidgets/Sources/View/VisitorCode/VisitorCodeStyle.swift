import UIKit

public struct VisitorCodeStyle: Equatable {
    // Color of the title text.
    public var titleColor: UIColor

    // Font of the title text.
    public var titleFont: UIFont

    /// Text style of the title text.
    public var titleTextStyle: UIFont.TextStyle

    /// Style of 'powered by' view.
    public var poweredBy: PoweredByStyle

    /// Style of the numberSlot
    public var numberSlot: NumberSlotStyle

    /// Style of an action button.
    public var actionButton: ActionButtonStyle

    /// Background color of the view.
    public var backgroundColor: ColorType

    /// Corner radius of the view.
    public var cornerRadius: CGFloat

    /// Border width of the view.
    public var borderWidth: CGFloat

    /// Border color of the view.
    public var borderColor: UIColor

    /// Color of the close button.
    public var closeButtonColor: ColorType

    /// Color of the loading progress.
    public var loadingProgressColor: UIColor

    /// Accessibility related properties.
    public var accessibility: Accessibility

    /// - Parameters:
    ///   - titleFont: Color of the title text.
    ///   - titleColor: Font of the title text.
    ///   - titleTextStyle: Text style of the title text.
    ///   - poweredBy: Style of 'powered by' view.
    ///   - numberSlot: Style of the numberSlot
    ///   - actionButton: Style of an action button.
    ///   - backgroundColor: Background color of the view.
    ///   - cornerRadius: Corner radius of the view.
    ///   - borderWidth: Border width of the view.
    ///   - borderColor: Border color of the view.
    ///   - closeButtonColor: Color of the close button.
    ///   - loadingProgressColor: Color of the loading progress.
    ///   - accessibility: Accessibility related properties.
    ///
    public init(
        titleFont: UIFont,
        titleColor: UIColor,
        titleTextStyle: UIFont.TextStyle = .title2,
        poweredBy: PoweredByStyle,
        numberSlot: NumberSlotStyle,
        actionButton: ActionButtonStyle,
        backgroundColor: ColorType,
        cornerRadius: CGFloat,
        borderWidth: CGFloat = 0,
        borderColor: UIColor = .clear,
        closeButtonColor: ColorType,
        loadingProgressColor: UIColor,
        accessibility: Accessibility = .unsupported
    ) {
        self.titleColor = titleColor
        self.titleFont = titleFont
        self.titleTextStyle = titleTextStyle
        self.poweredBy = poweredBy
        self.numberSlot = numberSlot
        self.actionButton = actionButton
        self.backgroundColor = backgroundColor
        self.cornerRadius = cornerRadius
        self.borderWidth = borderWidth
        self.borderColor = borderColor
        self.closeButtonColor = closeButtonColor
        self.loadingProgressColor = loadingProgressColor
        self.accessibility = accessibility
    }
}
