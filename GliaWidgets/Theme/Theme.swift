import UIKit

public struct Theme {
    private typealias Strings = L10n

    public var chat: ChatStyle

    let color: ThemeColor
    let font: ThemeFont

    public init(colorStyle: ThemeColorStyle = .default,
                fontStyle: ThemeFontStyle = .default) {
        self.color = colorStyle.color
        self.font = fontStyle.font

        let chatHeader = HeaderStyle(title: Strings.Chat.title,
                                     titleFont: Font.headerTitle,
                                     titleColor: color.baseLight,
                                     leftItemColor: color.baseLight,
                                     rightItemColor: color.baseLight,
                                     backgroundColor: color.primary)
        let sentChatMessage = ChatMessageStyle(messageFont: font.bodyText,
                                               messageColor: color.baseLight,
                                               backgroundColor: color.primary)
        let receivedChatMessage = ChatMessageStyle(messageFont: font.bodyText,
                                                   messageColor: color.baseDark,
                                                   backgroundColor: Color.lightGrey)
        chat = ChatStyle(header: chatHeader,
                         sentMessage: sentChatMessage,
                         receivedMessage: receivedChatMessage,
                         backgroundColor: color.background)
    }
}
