import UIKit

/// Style of an alert view.
public struct AlertStyle {
    /// Font of the title text.
    public var titleFont: UIFont

    /// Color of the title text.
    public var titleColor: UIColor

    /// Color of the title image.
    public var titleImageColor: UIColor

    /// Font of the message text.
    public var messageFont: UIFont

    /// Color of the message text.
    public var messageColor: UIColor

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
    ///   - titleImageColor: Color of the title image.
    ///   - messageFont: Font of the message text.
    ///   - messageColor: Color of the message text.
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
        titleImageColor: UIColor,
        messageFont: UIFont,
        messageColor: UIColor,
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
        self.titleImageColor = titleImageColor
        self.messageFont = messageFont
        self.messageColor = messageColor
        self.backgroundColor = backgroundColor
        self.closeButtonColor = closeButtonColor
        self.actionAxis = actionAxis
        self.positiveAction = positiveAction
        self.negativeAction = negativeAction
        self.poweredBy = poweredBy
        self.accessibility = accessibility
    }

    /// Apply alert customization from remote configuration
    mutating func applyAlertConfiguration(_ alert: RemoteConfiguration.Alert?) {
        positiveAction.applyActionButtonCustomization(alert?.positiveButton)
        negativeAction.applyActionButtonCustomization(alert?.negativeButton)

        UIFont.convertToFont(font: alert?.title?.font).map {
            titleFont = $0
        }

        alert?.title?.foreground?.type.map { colorType in
            switch colorType {
            case .fill:
                alert?.title?.foreground?.value.map {
                    titleColor = UIColor(hex: $0[0])
                }
            case .gradient:

            /// The logic for gradient has not been implemented

                break
            }
        }

        alert?.titleImageColor?.type.map { colorType in
            switch colorType {
            case .fill:
                alert?.titleImageColor?.value.map {
                    titleImageColor = UIColor(hex: $0[0])
                }
            case .gradient:

            /// The logic for gradient has not been implemented

                break
            }
        }

        UIFont.convertToFont(font: alert?.message?.font).map {
            messageFont = $0
        }

        alert?.message?.foreground?.type.map { colorType in
            switch colorType {
            case .fill:
                alert?.message?.foreground?.value.map {
                    messageColor = UIColor(hex: $0[0])
                }
            case .gradient:

            /// The logic for gradient has not been implemented

                break
            }
        }

        alert?.closeButtonColor?.type.map { colorType in
            switch colorType {
            case .fill:
                alert?.closeButtonColor?.value.map {
                    closeButtonColor = UIColor(hex: $0[0])
                }
            case .gradient:

            /// The logic for gradient has not been implemented

                break
            }
        }

        alert?.buttonAxis.map { axis in
            switch axis {
            case .horizontal:
                actionAxis = .horizontal
            case .vertical:
                actionAxis = .vertical
            }
        }
    }
}
