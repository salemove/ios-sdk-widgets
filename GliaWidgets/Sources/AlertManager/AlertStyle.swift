import UIKit

/// Style of an alert view.
public struct AlertStyle: Equatable {
    /// Font of the title text.
    public var titleFont: UIFont

    /// Color of the title text.
    public var titleColor: UIColor

    /// Text style of the title text.
    public var titleTextStyle: UIFont.TextStyle

    /// Color of the title image.
    public var titleImageColor: UIColor

    /// Font of the message text.
    public var messageFont: UIFont

    /// Color of the message text.
    public var messageColor: UIColor

    /// Text style of the message text.
    public var messageTextStyle: UIFont.TextStyle

    /// Background color of the view.
    public var backgroundColor: ColorType

    /// Color of the close button.
    public var closeButtonColor: ColorType

    /// Style of the first link action button.
    public var firstLinkAction: ActionButtonStyle

    /// Style of the second link action button.
    public var secondLinkAction: ActionButtonStyle

    /// Direction of the action buttons.
    public var actionAxis: NSLayoutConstraint.Axis

    /// Style of a positive action button.
    public var positiveAction: ActionButtonStyle

    /// Style of a negative action button.
    public var negativeAction: ActionButtonStyle

    /// Style of 'powered by' view.
    public var poweredBy: PoweredByStyle

    /// Accessibility related properties.
    public var accessibility: Accessibility

    /// - Parameters:
    ///   - titleFont: Font of the title text.
    ///   - titleColor: Color of the title text.
    ///   - titleTextStyle: Text style of the title text.
    ///   - titleImageColor: Color of the title image.
    ///   - messageFont: Font of the message text.
    ///   - messageColor: Color of the message text.
    ///   - messageTextStyle: Text style of the message text.
    ///   - backgroundColor: Background color of the view.
    ///   - closeButtonColor: Color of the close button.
    ///   - firstLinkAction: Style of the first link action button.
    ///   - secondLinkAction: Style of the second link action button.
    ///   - actionAxis: Direction of the action buttons.
    ///   - positiveAction: Style of a positive action button.
    ///   - negativeAction: Style of a negative action button.
    ///   - poweredBy: Style of 'powered by' view.
    ///   - accessibility: Accessibility related properties.
    ///
    public init(
        titleFont: UIFont,
        titleColor: UIColor,
        titleTextStyle: UIFont.TextStyle = .title2,
        titleImageColor: UIColor,
        messageFont: UIFont,
        messageColor: UIColor,
        messageTextStyle: UIFont.TextStyle = .body,
        backgroundColor: ColorType,
        closeButtonColor: ColorType,
        firstLinkAction: ActionButtonStyle,
        secondLinkAction: ActionButtonStyle,
        actionAxis: NSLayoutConstraint.Axis,
        positiveAction: ActionButtonStyle,
        negativeAction: ActionButtonStyle,
        poweredBy: PoweredByStyle,
        accessibility: Accessibility = .unsupported
    ) {
        self.titleFont = titleFont
        self.titleColor = titleColor
        self.titleTextStyle = titleTextStyle
        self.titleImageColor = titleImageColor
        self.messageFont = messageFont
        self.messageColor = messageColor
        self.messageTextStyle = messageTextStyle
        self.backgroundColor = backgroundColor
        self.closeButtonColor = closeButtonColor
        self.firstLinkAction = firstLinkAction
        self.secondLinkAction = secondLinkAction
        self.actionAxis = actionAxis
        self.positiveAction = positiveAction
        self.negativeAction = negativeAction
        self.poweredBy = poweredBy
        self.accessibility = accessibility
    }
}
