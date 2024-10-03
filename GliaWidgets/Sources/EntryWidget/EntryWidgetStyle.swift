import UIKit

public struct EntryWidgetStyle {
    /// The style of a media type item.
    public var mediaTypeItem: MediaTypeItemStyle

    /// The background color of the view.
    public var backgroundColor: ColorType

    /// The corner radius of the view.
    public var cornerRadius: CGFloat

    /// The style of 'powered by' view.
    public var poweredBy: PoweredByStyle

    /// The color of the divider.
    public var dividerColor: UIColor

    /// The font for the title of the error message.
    public var errorTitleFont: UIFont

    /// The text style for the title of the error message.
    public var errorTitleStyle: UIFont.TextStyle

    /// The color for the title of the error message.
    public var errorTitleColor: UIColor

    /// The error message string.
    public var errorMessageFont: UIFont

    /// The text style for the error message.
    public var errorMessageStyle: UIFont.TextStyle

    /// The color for the error message.
    public var errorMessageColor: UIColor

    /// The style of the error button.
    public var errorButton: ActionButtonStyle

    /// - Parameters:
    ///   - mediaTypeItem: The style of a media type item.
    ///   - backgroundColor: The background color of the view.
    ///   - cornerRadius: The corner radius of the view.
    ///   - poweredBy: The style of the 'powered by' view.
    ///   - dividerColor: The color of the divider.
    ///   - errorTitleFont: The font for the title of the error message.
    ///   - errorTitleStyle: The text style for the title of the error message.
    ///   - errorTitleColor: The color for the title of the error message.
    ///   - errorMessage: The error message string.
    ///   - errorMessageStyle: The text style for the error message.
    ///   - errorMessageColor: The color for the error message.
    ///   - errorButton: The style of the error button.
    public init(
        mediaTypeItem: MediaTypeItemStyle,
        backgroundColor: ColorType,
        cornerRadius: CGFloat,
        poweredBy: PoweredByStyle,
        dividerColor: UIColor,
        errorTitleFont: UIFont,
        errorTitleStyle: UIFont.TextStyle,
        errorTitleColor: UIColor,
        errorMessageFont: UIFont,
        errorMessageStyle: UIFont.TextStyle,
        errorMessageColor: UIColor,
        errorButton: ActionButtonStyle
    ) {
        self.mediaTypeItem = mediaTypeItem
        self.backgroundColor = backgroundColor
        self.cornerRadius = cornerRadius
        self.poweredBy = poweredBy
        self.dividerColor = dividerColor
        self.errorTitleFont = errorTitleFont
        self.errorTitleStyle = errorTitleStyle
        self.errorTitleColor = errorTitleColor
        self.errorMessageFont = errorMessageFont
        self.errorMessageStyle = errorMessageStyle
        self.errorMessageColor = errorMessageColor
        self.errorButton = errorButton
    }
}
