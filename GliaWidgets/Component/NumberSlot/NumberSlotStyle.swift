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

    ///
    /// - Parameters:
    ///   - backgroundColor: Color of the background.
    ///   - borderColor: Border color of the view.
    ///   - borderWidth: Border width of the view.
    ///   - cornerRadius: Corner radius of the view.
    ///   - numberColor: Color of the number.
    ///   - numberFont: Font of the number.
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

    mutating func apply(
        configuration: RemoteConfiguration.NumberSlot?,
        assetsBuilder: RemoteConfiguration.AssetsBuilder
    ) {
        UIFont.convertToFont(
            uiFont: assetsBuilder.fontBuilder(configuration?.font),
            textStyle: numberStyle
        ).unwrap { numberFont = $0 }

        configuration?.fontColor?.value
            .map { UIColor(hex: $0) }
            .first
            .unwrap { numberColor = $0 }

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

        configuration?.background?.cornerRadius
            .unwrap { cornerRadius = $0 }

        configuration?.background?.borderWidth
            .unwrap { borderWidth = $0 }

        configuration?.background?.border?.value
            .map { UIColor(hex: $0) }
            .first
            .unwrap { borderColor = $0 }
    }
}
