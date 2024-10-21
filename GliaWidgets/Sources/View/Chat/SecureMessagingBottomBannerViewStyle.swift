import UIKit

/// Style of the secure messaging bottom banner view.
public struct SecureMessagingBottomBannerViewStyle: Equatable {
    /// Text of the banner message.
    public var message: String
    /// Font of banner message.
    public var font: UIFont
    /// Color of the text of the  banner message.
    public var textColor: UIColor
    /// Color of the banner background.
    public var backgroundColor: UIColor
    /// Color of the banner divider.
    public var dividerColor: UIColor

    /// - Parameters:
    ///   - message: Text of the banner message.
    ///   - font: Font of banner message.
    ///   - textColor: Color of the text of the  banner message.
    ///   - backgroundColor: Color of the banner background.
    ///   - dividerColor: Color of the banner divider.
    public init(
        message: String,
        font: UIFont,
        textColor: UIColor,
        backgroundColor: UIColor,
        dividerColor: UIColor
    ) {
        self.message = message
        self.font = font
        self.textColor = textColor
        self.backgroundColor = backgroundColor
        self.dividerColor = dividerColor
    }
}

extension SecureMessagingBottomBannerViewStyle {
    static let initial = Self(
        message: "",
        font: .preferredFont(forTextStyle: .caption1),
        textColor: .label,
        backgroundColor: .red,
        dividerColor: .yellow
    )
}
