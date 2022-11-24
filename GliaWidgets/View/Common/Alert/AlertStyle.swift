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
    public var backgroundColor: ColorType

    /// Color of the close button.
    public var closeButtonColor: ColorType

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
        backgroundColor: ColorType,
        closeButtonColor: ColorType,
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
    mutating func apply(
        configuration: RemoteConfiguration.Alert?,
        assetsBuilder: RemoteConfiguration.AssetsBuilder
    ) {
        positiveAction.apply(
            configuration: configuration?.positiveButton,
            assetsBuilder: assetsBuilder
        )
        negativeAction.apply(
            configuration: configuration?.negativeButton,
            assetsBuilder: assetsBuilder
        )
        applyTitleConfiguration(
            configuration?.title,
            assetsBuilder: assetsBuilder
        )
        applyTitleImageConfiguration(configuration?.titleImageColor)
        applyMessageConfiguration(
            configuration?.message,
            assetsBuilder: assetsBuilder
        )
    }
}

// MARK: - Private

private extension AlertStyle {

    mutating func applyTitleConfiguration(
        _ configuration: RemoteConfiguration.Text?,
        assetsBuilder: RemoteConfiguration.AssetsBuilder
    ) {
        UIFont.convertToFont(
            uiFont: assetsBuilder.fontBuilder(configuration?.font),
            textStyle: titleTextStyle
        ).unwrap { titleFont = $0 }

        configuration?.foreground?.value
            .map { UIColor(hex: $0) }
            .first
            .unwrap { titleColor = $0 }
    }

    mutating func applyTitleImageConfiguration(_ configuration: RemoteConfiguration.Color?) {
        configuration?.value
            .map { UIColor(hex: $0) }
            .first
            .unwrap { titleImageColor = $0 }
    }

    mutating func applyMessageConfiguration(
        _ configuration: RemoteConfiguration.Text?,
        assetsBuilder: RemoteConfiguration.AssetsBuilder
    ) {
        UIFont.convertToFont(
            uiFont: assetsBuilder.fontBuilder(configuration?.font),
            textStyle: messageTextStyle
        ).unwrap { messageFont = $0 }

        configuration?.foreground?.value
            .map { UIColor(hex: $0) }
            .first
            .unwrap { messageColor = $0 }
    }

    mutating func applyBackgroundConfiguration(_ configuration: RemoteConfiguration.Color?) {
        configuration.unwrap {
            switch $0.type {
            case .fill:
                $0.value
                    .map { UIColor(hex: $0) }
                    .first
                    .unwrap { backgroundColor = .fill(color: $0) }
            case .gradient:
                let colors = $0.value.convertToCgColors()
                backgroundColor = .gradient(colors: colors)
            }
        }
    }

    mutating func applyButtonAxisConfiguration(_ configuration: RemoteConfiguration.Axis?) {
        configuration.unwrap { axis in
            switch axis {
            case .horizontal:
                actionAxis = .horizontal
            case .vertical:
                actionAxis = .vertical
            }
        }
    }

    mutating func applyCloseButtonConfiguration(_ configuration: RemoteConfiguration.Color?) {
        configuration.unwrap {
            switch $0.type {
            case .fill:
                $0.value
                    .map { UIColor(hex: $0) }
                    .first
                    .unwrap { closeButtonColor = .fill(color: $0) }
            case .gradient:
                let colors = $0.value.convertToCgColors()
                closeButtonColor = .gradient(colors: colors)
            }
        }
    }
}
