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
            text: configuration?.numberSlotText,
            background: configuration?.numberSlotBackground,
            assetsBuilder: assetBuilder
        )

        configuration?.loadingProgressColor?.value
            .map { UIColor(hex: $0) }
            .first
            .unwrap { loadingProgressColor = $0 }

        configuration?.background?.cornerRadius
            .unwrap { cornerRadius = $0 }

        configuration?.background?.borderWidth
            .unwrap { borderWidth = $0 }

        configuration?.background?.border?.value
            .map { UIColor(hex: $0) }
            .first
            .unwrap { borderColor = $0 }

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

        configuration?.closeButtonColor?.value
            .map { UIColor(hex: $0) }
            .first
            .unwrap { closeButtonColor = .fill(color: $0) }
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
