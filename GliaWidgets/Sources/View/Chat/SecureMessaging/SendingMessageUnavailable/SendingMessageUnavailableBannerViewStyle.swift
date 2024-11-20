import UIKit

/// Style for unavailability to send messages banner view.
public struct SendingMessageUnavailableBannerViewStyle: Equatable {
    /// Text of the banner message.
    public var message: String
    /// Font of banner message.
    public var font: UIFont
    /// Style of the text of the  banner message.
    public var textStyle: UIFont.TextStyle
    /// Color of the text of the  banner message.
    public var textColor: UIColor
    /// Color of the banner background.
    public var backgroundColor: ColorType
    /// Color of the info icon.
    public var iconColor: UIColor

    /// - Parameters:
    ///   - message: Text of the banner message.
    ///   - font: Font of banner message.
    ///   - textStyle: Style of the text of the  banner message.
    ///   - textColor: Color of the text of the  banner message.
    ///   - backgroundColor: Color of the banner background.
    public init(
        message: String,
        font: UIFont,
        textStyle: UIFont.TextStyle,
        textColor: UIColor,
        backgroundColor: ColorType,
        iconColor: UIColor
    ) {
        self.message = message
        self.font = font
        self.textColor = textColor
        self.backgroundColor = backgroundColor
        self.textStyle = textStyle
        self.iconColor = iconColor
    }
}

extension SendingMessageUnavailableBannerViewStyle {
    static let initial = Self(
        message: "",
        font: .preferredFont(forTextStyle: .caption1),
        textStyle: .caption1,
        textColor: .label,
        backgroundColor: .fill(color: .red),
        iconColor: .label
    )
}
