import UIKit

/// Style of the secure messaging top banner view.
public struct SecureMessagingTopBannerViewStyle: Equatable {
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
    /// Image of the banner button.
    public var buttonImage: UIImage
    /// Color of the banner button image.
    public var buttonImageColor: UIColor
    /// Accessibility properties for SecureMessagingBottomBannerViewStyle.
    public var accessibility: Accessibility

    /// - Parameters:
    ///   - message: Text of the banner message.
    ///   - font: Font of need banner message.
    ///   - textStyle: Style of the text of the banner message.
    ///   - textColor: Color of the text of the banner message.
    ///   - backgroundColor: Color of the banner background.
    ///   - dividerColor: Color of the banner divider.
    public init(
        message: String,
        font: UIFont,
        textStyle: UIFont.TextStyle,
        textColor: UIColor,
        backgroundColor: ColorType,
        dividerColor: UIColor,
        buttonImage: UIImage,
        buttonImageColor: UIColor,
        accessibility: Accessibility
    ) {
        self.message = message
        self.font = font
        self.textColor = textColor
        self.backgroundColor = backgroundColor
        self.dividerColor = dividerColor
        self.textStyle = textStyle
        self.buttonImage = buttonImage
        self.buttonImageColor = buttonImageColor
        self.accessibility = accessibility
    }
}

extension SecureMessagingTopBannerViewStyle {
    static let initial = Self(
        message: "",
        font: .preferredFont(forTextStyle: .body),
        textStyle: .body,
        textColor: .label,
        backgroundColor: .fill(color: .white),
        dividerColor: .lightGray,
        buttonImage: Asset.chevronDownIcon.image,
        buttonImageColor: .darkGray,
        accessibility: .init(isFontScalingEnabled: true)
    )
}
