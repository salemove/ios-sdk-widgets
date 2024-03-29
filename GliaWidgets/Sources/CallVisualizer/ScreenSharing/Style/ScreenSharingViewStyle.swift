import UIKit

public struct ScreenSharingViewStyle: Equatable {
    /// Title of the view's header (navigation bar area).
    public var title: String

    /// Style of the view's header (navigation bar area).
    public var header: HeaderStyle

    /// The text shown above the end screen sharing button.
    public var messageText: String

    /// Font of the message text.
    public var messageTextFont: UIFont

    /// Color of the message text.
    public var messageTextColor: UIColor

    /// Text style of the message text.
    public var messageTextStyle: UIFont.TextStyle

    /// Style of end screen sharing button.
    public var buttonStyle: ActionButtonStyle

    /// End screen sharing button icon.
    public var buttonIcon: UIImage

    /// Style for root view background color.
    public var backgroundColor: ColorType

    /// Accessibility related properties.
    public var accessibility: Accessibility

    /// Initialize the style for CallVisualizer.ScreenSharingView
    /// - Parameters:
    ///   - title: Title of the view's header (navigation bar area).
    ///   - header: Style of the view's header (navigation bar area).
    ///   - messageText: The text shown above the end screen sharing button.
    ///   - messageTextFont: Font of the message text.
    ///   - messageTextColor: Color of the message text.
    ///   - messageTextStyle: Text style of the message text.
    ///   - buttonStyle: Style of end screen sharing button.
    ///   - buttonIcon: End screen sharing button icon.
    ///   - backgroundColor: Style for root view background color.
    ///   - accessibility: Accessibility related properties.
    ///
    public init(
        title: String,
        header: HeaderStyle,
        messageText: String,
        messageTextFont: UIFont,
        messageTextColor: UIColor,
        messageTextStyle: UIFont.TextStyle = .title2,
        buttonStyle: ActionButtonStyle,
        buttonIcon: UIImage,
        backgroundColor: ColorType,
        accessibility: Accessibility
    ) {
        self.title = title
        self.header = header
        self.messageText = messageText
        self.messageTextFont = messageTextFont
        self.messageTextColor = messageTextColor
        self.messageTextStyle = messageTextStyle
        self.buttonStyle = buttonStyle
        self.buttonIcon = buttonIcon
        self.backgroundColor = backgroundColor
        self.accessibility = accessibility
    }
}
