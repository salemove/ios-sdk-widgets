import UIKit

/// Style of the secure messaging bottom banner view.
public struct SecureMessagingBottomBannerViewStyle: Equatable {
    /// Text of the banner message.
    public var message: String
    /// Font of banner message.
    public var font: UIFont
    /// Style of the text of the banner message.
    public var textStyle: UIFont.TextStyle
    /// Color of the text of the banner message.
    public var textColor: UIColor
    /// Color of the banner background.
    public var backgroundColor: ColorType
    /// Color of the banner divider.
    public var dividerColor: UIColor
    /// Accessibility properties for SecureMessagingBottomBannerViewStyle.
    public var accessibility: Accessibility

    /// - Parameters:
    ///   - message: Text of the banner message.
    ///   - font: Font of banner message.
    ///   - textStyle: Style of the text of the banner message.
    ///   - textColor: Color of the text of the banner message.
    ///   - backgroundColor: Color of the banner background.
    ///   - dividerColor: Color of the banner divider.
    ///   - accessibility: Accessibility properties for SecureMessagingBottomBannerViewStyle.
    public init(
        message: String,
        font: UIFont,
        textStyle: UIFont.TextStyle,
        textColor: UIColor,
        backgroundColor: ColorType,
        dividerColor: UIColor,
        accessibility: Accessibility
    ) {
        self.message = message
        self.font = font
        self.textColor = textColor
        self.backgroundColor = backgroundColor
        self.dividerColor = dividerColor
        self.textStyle = textStyle
        self.accessibility = accessibility
    }
}

extension SecureMessagingBottomBannerViewStyle {
    static let initial = Self(
        message: "",
        font: .preferredFont(forTextStyle: .caption1),
        textStyle: .caption1,
        textColor: .label,
        backgroundColor: .fill(color: .red),
        dividerColor: .yellow,
        accessibility: .init(isFontScalingEnabled: true)
    )
}
