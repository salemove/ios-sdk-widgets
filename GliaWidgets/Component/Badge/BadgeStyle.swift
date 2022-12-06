import UIKit

/// Style of a badge view. A badge is used to show unread message count on the minimized bubble and on the chat button in the call view.
public struct BadgeStyle {
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

    ///
    /// - Parameters:
    ///   - font: Font of the text.
    ///   - fontColor: Color of the text.
    ///   - textStyle: Text style of the text.
    ///   - backgroundColor: Background color of the view.
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

    /// Apply badge remote configuration
    mutating func apply(
        configuration: RemoteConfiguration.Badge?,
        assetsBuilder: RemoteConfiguration.AssetsBuilder
    ) {
        UIFont.convertToFont(
            uiFont: assetsBuilder.fontBuilder(configuration?.font),
            textStyle: textStyle
        ).unwrap { font = $0 }

        configuration?.fontColor?.value
            .map { UIColor(hex: $0) }
            .first
            .unwrap { fontColor = $0 }

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

        configuration?.background?.border.unwrap {
            switch $0.type {
            case .fill:
                $0.value
                    .map { UIColor(hex: $0) }
                    .first
                    .unwrap { borderColor = .fill(color: $0) }
            case .gradient:
                break
            }
        }

        configuration?.background?.borderWidth
            .unwrap { borderWidth = $0 }
    }
}
