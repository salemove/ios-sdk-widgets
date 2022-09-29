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

    /// Font of the duration counter text.
    public var durationFont: UIFont

    /// Color of the duration counter text.
    public var durationColor: UIColor

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
    ///   - durationFont: Font of the duration counter text.
    ///   - durationColor: Color of the duration counter text.
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
        durationFont: UIFont,
        durationColor: UIColor,
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
        self.durationFont = durationFont
        self.durationColor = durationColor
        self.borderColor = borderColor
        self.borderWidth = borderWidth
        self.cornerRadius = cornerRadius
        self.accessibility = accessibility
    }

    func apply(configuration: RemoteConfiguration.Upgrade?) {
        configuration?.iconColor?.value
            .map { UIColor(hex: $0) }
            .first
            .map { iconColor = $0 }

        configuration?.text?.font?.size
            .map { textFont = Font.regular($0) }

        configuration?.text?.foreground?.value
            .map { UIColor(hex: $0) }
            .first
            .map { textColor = $0 }

        configuration?.description?.font?.size
            .map { durationFont = Font.regular($0) }

        configuration?.description?.foreground?.value
            .map { UIColor(hex: $0) }
            .first
            .map { durationColor = $0 }

        configuration?.background?.border?.value
            .map { UIColor(hex: $0) }
            .first
            .map { borderColor = $0 }

        configuration?.background?.borderWidth
            .map { borderWidth = $0 }

        configuration?.background?.cornerRadius
            .map { cornerRadius = $0 }
    }
}
