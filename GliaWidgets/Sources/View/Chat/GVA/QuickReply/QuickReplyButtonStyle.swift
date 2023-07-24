import UIKit

/// Style of the GVA Quick Reply Button
public struct GvaQuickReplyButtonStyle {
    /// Font of the button
    public var textFont: UIFont

    /// Color of the button
    public var textColor: UIColor

    /// Text style of the button
    public var textStyle: UIFont.TextStyle

    /// Background of the button
    public var backgroundColor: ColorType

    /// Corner radius of the button
    public var cornerRadius: CGFloat

    /// Border color of the button
    public var borderColor: UIColor

    /// Border width of the button
    public var borderWidth: CGFloat

    init(
        textFont: UIFont,
        textColor: UIColor,
        textStyle: UIFont.TextStyle = .title2,
        backgroundColor: ColorType,
        cornerRadius: CGFloat,
        borderColor: UIColor,
        borderWidth: CGFloat
    ) {
        self.textFont = textFont
        self.textColor = textColor
        self.textStyle = textStyle
        self.backgroundColor = backgroundColor
        self.cornerRadius = cornerRadius
        self.borderColor = borderColor
        self.borderWidth = borderWidth
    }

    mutating func apply(
        _ configuration: RemoteConfiguration.Button?,
        assetBuilder: RemoteConfiguration.AssetsBuilder
    ) {
        applyTitleConfiguration(configuration?.text, assetBuilder: assetBuilder)
        applyBackgroundConfiguration(configuration?.background)
    }

    mutating private func applyTitleConfiguration(
        _ configuration: RemoteConfiguration.Text?,
        assetBuilder: RemoteConfiguration.AssetsBuilder
    ) {
        UIFont.convertToFont(
            uiFont: assetBuilder.fontBuilder(configuration?.font),
            textStyle: textStyle
        ).unwrap { textFont = $0 }

        configuration?.foreground?.value
            .map { UIColor(hex: $0) }
            .first
            .unwrap { textColor = $0 }
    }

    mutating private func applyBackgroundConfiguration(_ configuration: RemoteConfiguration.Layer?) {
        configuration?.border?.value
            .map { UIColor(hex: $0) }
            .first
            .unwrap { borderColor = $0 }

        configuration?.borderWidth
            .unwrap { borderWidth = $0 }

        configuration?.cornerRadius
            .unwrap { cornerRadius = $0 }

        configuration?.color.unwrap {
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
