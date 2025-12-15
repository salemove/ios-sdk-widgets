import UIKit

public struct MediaQualityIndicatorStyle {
    /// Indicator text.
    public var text: String

    /// Indicator text font.
    public var font: UIFont

    /// Indicator foreground color.
    public var foreground: UIColor

    /// Indicator background color.
    public var background: ColorType

    /// Text alignment within the indicator.
    public var alignment: NSTextAlignment

    /// Style accessibility.
    public var accessibility: Accessibility

    /// - Parameters:
    ///   - text: Indicator text.
    ///   - textFont: Indicator text font.
    ///   - background: Indicator background color.
    ///   - foreground: Indicator foreground (text) color.
    ///   - alignment: Text alignment within the indicator.
    public init(
        text: String,
        textFont: UIFont,
        background: ColorType,
        foreground: UIColor,
        alignment: NSTextAlignment,
        accessibility: Accessibility
    ) {
        self.text = text
        self.font = textFont
        self.background = background
        self.foreground = foreground
        self.alignment = alignment
        self.accessibility = accessibility
    }
}
