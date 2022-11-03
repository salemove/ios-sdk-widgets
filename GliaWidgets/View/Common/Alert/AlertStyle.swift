import UIKit

/// Style of an alert view.
public struct AlertStyle {
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
    public var backgroundColor: UIColor

    /// Color of the close button.
    public var closeButtonColor: UIColor

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

    ///
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
        backgroundColor: UIColor,
        closeButtonColor: UIColor,
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
        self.actionAxis = actionAxis
        self.positiveAction = positiveAction
        self.negativeAction = negativeAction
        self.poweredBy = poweredBy
        self.accessibility = accessibility
    }

    /// Apply alert customization from remote configuration
    mutating func apply(configuration: RemoteConfiguration.Alert?) {
        positiveAction.apply(configuration: configuration?.positiveButton)
        negativeAction.apply(configuration: configuration?.negativeButton)
        applyTitleConfiguration(configuration?.title)
        applyTitleImageConfiguration(configuration?.titleImageColor)
        applyMessageConfiguration(configuration?.message)

        switch configuration?.closeButtonColor?.type {
        case .fill:
            configuration?.closeButtonColor?.value
                .map(UIColor.init(hex:))
                .first
                .map { closeButtonColor = $0 }
        case .gradient, .none:
            // The logic for gradient has not been implemented
            break
        }

        configuration?.buttonAxis.map { axis in
            switch axis {
            case .horizontal:
                actionAxis = .horizontal
            case .vertical:
                actionAxis = .vertical
            }
        }

        switch configuration?.backgroundColor?.type {
        case .fill:
            configuration?.backgroundColor?.value
                .map(UIColor.init(hex:))
                .first
                .map { backgroundColor = $0 }
        case .gradient, .none:
            // The logic for gradient has not been implemented
            break
        }
    }
}

// MARK: - Private

private extension AlertStyle {

    mutating func applyTitleConfiguration(_ configuration: RemoteConfiguration.Text?) {
        UIFont.convertToFont(
            font: configuration?.font,
            textStyle: titleTextStyle
        ).map { titleFont = $0 }

        switch configuration?.foreground?.type {
        case .fill:
            configuration?.foreground?.value
                .map(UIColor.init(hex:))
                .first
                .map { titleColor = $0 }
        case .gradient, .none:
            // The logic for gradient has not been implemented
            break
        }
    }

    mutating func applyTitleImageConfiguration(_ configuration: RemoteConfiguration.Color?) {
        switch configuration?.type {
        case .fill:
            configuration?.value
                .map(UIColor.init(hex:))
                .first
                .map { titleImageColor = $0 }
        case .gradient, .none:
            // The logic for gradient has not been implemented
            break
        }
    }

    mutating func applyMessageConfiguration(_ configuration: RemoteConfiguration.Text?) {
        UIFont.convertToFont(
            font: configuration?.font,
            textStyle: messageTextStyle
        ).map { messageFont = $0 }

        switch configuration?.foreground?.type {
        case .fill:
            configuration?.foreground?.value
                .map(UIColor.init(hex:))
                .first
                .map { messageColor = $0 }
        case .gradient, .none:
            // The logic for gradient has not been implemented
            break
        }
    }
}
