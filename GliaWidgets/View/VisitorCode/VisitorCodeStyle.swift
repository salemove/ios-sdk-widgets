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

    /// Color of the close button.
    public var closeButtonColor: ColorType

    /// Accessibility related properties.
    public var accessibility: Accessibility

    public init(
        titleFont: UIFont,
        titleColor: UIColor,
        titleTextStyle: UIFont.TextStyle = .title2,
        poweredBy: PoweredByStyle,
        numberSlot: NumberSlotStyle,
        actionButton: ActionButtonStyle,
        accessibility: Accessibility = .unsupported,
        backgroundColor: ColorType,
        cornerRadius: CGFloat,
        closeButtonColor: ColorType
    ) {
        self.titleColor = titleColor
        self.titleFont = titleFont
        self.titleTextStyle = titleTextStyle
        self.poweredBy = poweredBy
        self.numberSlot = numberSlot
        self.actionButton = actionButton
        self.accessibility = accessibility
        self.cornerRadius = cornerRadius
        self.backgroundColor = backgroundColor
        self.closeButtonColor = closeButtonColor
    }

    mutating func apply(
        configuration: RemoteConfiguration.VisitorCode?,
        assetBuilder: RemoteConfiguration.AssetsBuilder
    ) {
        applyTitleConfiguration(
            configuration?.title,
            assetsBuilder: assetBuilder
        )
        actionButton.apply(
            configuration: configuration?.actionButton,
            assetsBuilder: assetBuilder
        )
        numberSlot.apply(
            configuration: configuration?.numberSlot,
            assetsBuilder: assetBuilder
        )

        configuration?.background?.cornerRadius
            .unwrap { cornerRadius = $0 }

        configuration?.background?.color.unwrap {
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
}

extension VisitorCodeStyle {

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
}
