import UIKit

public struct Theme {
    private typealias Strings = L10n

    public let primaryColor: UIColor
    public let secondaryColor: UIColor
    public let baseNormalColor: UIColor
    public let baseLightColor: UIColor
    public let baseDarkColor: UIColor
    public let baseShadeColor: UIColor
    public let backgroundColor: UIColor
    public let systemNegativeColor: UIColor
    public let header1Font: UIFont
    public let header2Font: UIFont
    public let header3Font: UIFont
    public let bodyTextFont: UIFont
    public let subtitleFont: UIFont
    public let captionFont: UIFont
    public var chat: ChatStyle

    public init(primaryColor: UIColor = Color.primary,
                secondaryColor: UIColor = Color.secondary,
                baseNormalColor: UIColor = Color.baseNormal,
                baseLightColor: UIColor = Color.baseLight,
                baseDarkColor: UIColor = Color.baseDark,
                baseShadeColor: UIColor = Color.baseShade,
                backgroundColor: UIColor = Color.background,
                systemNegativeColor: UIColor = Color.systemNegative,
                header1Font: UIFont = Font.header1,
                header2Font: UIFont = Font.header2,
                header3Font: UIFont = Font.header3,
                bodyTextFont: UIFont = Font.bodyText,
                subtitleFont: UIFont = Font.subtitle,
                captionFont: UIFont = Font.caption) {
        self.primaryColor = primaryColor
        self.secondaryColor = secondaryColor
        self.baseNormalColor = baseNormalColor
        self.baseLightColor = baseLightColor
        self.baseDarkColor = baseDarkColor
        self.baseShadeColor = baseShadeColor
        self.backgroundColor = backgroundColor
        self.systemNegativeColor = systemNegativeColor
        self.header1Font = header1Font
        self.header2Font = header2Font
        self.header3Font = header3Font
        self.bodyTextFont = bodyTextFont
        self.subtitleFont = subtitleFont
        self.captionFont = captionFont

        let chatHeader = HeaderStyle(title: Strings.Chat.title,
                                     titleFont: Font.headerTitle,
                                     titleColor: baseLightColor,
                                     leftItemColor: baseLightColor,
                                     rightItemColor: baseLightColor,
                                     backgroundColor: primaryColor)
        let sentChatMessage = ChatMessageStyle(messageFont: bodyTextFont,
                                               messageColor: baseLightColor,
                                               backgroundColor: primaryColor)
        let receivedChatMessage = ChatMessageStyle(messageFont: bodyTextFont,
                                                   messageColor: baseDarkColor,
                                                   backgroundColor: Color.lightGrey)
        chat = ChatStyle(header: chatHeader,
                         sentMessage: sentChatMessage,
                         receivedMessage: receivedChatMessage,
                         backgroundColor: backgroundColor)
    }
}
