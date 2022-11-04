import UIKit

/// Style of the call upgrade view. Shown after engagement is upgraded to a call.
public class ChatCallUpgradeStyle {
    /// An icon indicating upgraded engagement kind.
    public var icon: UIImage

    /// Color of the icon image.
    public var iconColor: UIColor

    /// Text to display in the view.
    public var text: String

    /// Font of the text.
    public var textFont: UIFont

    /// Color of the text.
    public var textColor: UIColor

    /// Text style of the text.
    public var textStyle: UIFont.TextStyle

    /// Font of the duration counter text.
    public var durationFont: UIFont

    /// Color of the duration counter text.
    public var durationColor: UIColor

    /// Text style of the duration counter text.
    public var durationTextStyle: UIFont.TextStyle

    /// Border color of the view.
    public var borderColor: UIColor

    /// Border width of the view.
    public var borderWidth: CGFloat

    /// Corner radius of the view.
    public var cornerRadius: CGFloat

    /// Accessibility related properties.
    public var accessibility: Accessibility

    ///
    /// - Parameters:
    ///   - icon: An icon indicating upgraded engagement kind.
    ///   - iconColor: Color of the icon image.
    ///   - text: Text to display in the view.
    ///   - textFont: Font of the text.
    ///   - textColor: Color of the text.
    ///   - textStyle: Text style of the text.
    ///   - durationFont: Font of the duration counter text.
    ///   - durationColor: Color of the duration counter text.
    ///   - durationTextStyle: Text style of the duration counter text.
    ///   - borderColor: Border color of the view.
    ///   - borderWidth: Border width of the view.
    ///   - cornerRadius: Corner radius of the view.
    ///   - accessibility: Accessibility related properties.
    ///
    public init(
        icon: UIImage,
        iconColor: UIColor,
        text: String,
        textFont: UIFont,
        textColor: UIColor,
        textStyle: UIFont.TextStyle = .body,
        durationFont: UIFont,
        durationColor: UIColor,
        durationTextStyle: UIFont.TextStyle = .body,
        borderColor: UIColor,
        borderWidth: CGFloat = 1,
        cornerRadius: CGFloat = 8,
        accessibility: Accessibility = .unsupported
    ) {
        self.icon = icon
        self.iconColor = iconColor
        self.text = text
        self.textFont = textFont
        self.textColor = textColor
        self.textStyle = textStyle
        self.durationFont = durationFont
        self.durationColor = durationColor
        self.durationTextStyle = durationTextStyle
        self.borderColor = borderColor
        self.borderWidth = borderWidth
        self.cornerRadius = cornerRadius
        self.accessibility = accessibility
    }

    func apply(configuration: RemoteConfiguration.Upgrade?) {
        configuration?.iconColor?.value
            .map { UIColor(hex: $0) }
            .first
            .unwrap { iconColor = $0 }

        UIFont.convertToFont(
            font: configuration?.text?.font,
            textStyle: textStyle
        ).unwrap { textFont = $0 }

        configuration?.text?.foreground?.value
            .map { UIColor(hex: $0) }
            .first
            .unwrap { textColor = $0 }

        UIFont.convertToFont(
            font: configuration?.description?.font,
            textStyle: durationTextStyle
        ).unwrap { durationFont = $0 }

        configuration?.description?.foreground?.value
            .map { UIColor(hex: $0) }
            .first
            .unwrap { durationColor = $0 }

        configuration?.background?.border?.value
            .map { UIColor(hex: $0) }
            .first
            .unwrap { borderColor = $0 }

        configuration?.background?.borderWidth
            .unwrap { borderWidth = $0 }

        configuration?.background?.cornerRadius
            .unwrap { cornerRadius = $0 }
    }
}
