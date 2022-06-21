import UIKit

/// Style of PoweredBy view (used in AlertView).
public struct PoweredByStyle {
    /// **Powered by** text.
    public var text: String
    /// Font used for `PoweredBy` view.
    public var font: UIFont
    /// Accessibility related properties.
    public var accessibility: Accessibility

    ///
    /// - Parameters:
    ///   - text: **Powered by** text.
    ///   - font: Font used for `PoweredBy` view.
    ///   - accessibility: Accessibility related properties.
    public init(
        text: String,
        font: UIFont,
        accessibility: Accessibility = .init(isFontScalingEnabled: true)
    ) {
        self.text = text
        self.font = font
        self.accessibility = accessibility
    }
}
