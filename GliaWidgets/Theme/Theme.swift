import UIKit

public class Theme {
    private typealias Strings = L10n

    public let color: ThemeColor
    public let font: ThemeFont

    public lazy var chat: ChatStyle = {
        typealias Chat = L10n.Chat
        typealias Queue = L10n.Queue

        let header = HeaderStyle(title: Chat.title,
                                 titleFont: font.header2,
                                 titleColor: color.baseLight,
                                 leftItemColor: color.baseLight,
                                 rightItemColor: color.baseLight,
                                 backgroundColor: color.primary)

        let queueOperator = QueueOperatorStyle(placeholderImage: Asset.chatOperatorPlaceholder.image,
                                               placeholderColor: color.baseLight,
                                               animationColor: color.primary)
        let enqueued = QueueStatusStyle(text1: Queue.Enqueued.text1,
                                        text1Font: font.header1,
                                        text1FontColor: color.baseDark,
                                        text2: Queue.Enqueued.text2,
                                        text2Font: font.subtitle,
                                        text2FontColor: color.baseNormal)
        let connecting = QueueStatusStyle(text1: Queue.Connecting.text1,
                                          text1Font: font.header2,
                                          text1FontColor: color.baseDark,
                                          text2: Queue.Connecting.text2,
                                          text2Font: font.header2,
                                          text2FontColor: color.baseDark)
        let connected = QueueStatusStyle(text1: Queue.Connected.text1,
                                         text1Font: font.header1,
                                         text1FontColor: color.baseDark,
                                         text2: Queue.Connected.text2,
                                         text2Font: font.subtitle,
                                         text2FontColor: color.primary)
        let queue = QueueStyle(queueOperator: queueOperator,
                               enqueued: enqueued,
                               connecting: connecting,
                               connected: connected)

        let sentMessage = ChatMessageStyle(messageFont: font.bodyText,
                                           messageColor: color.baseLight,
                                           backgroundColor: color.primary)
        let receivedMessage = ChatMessageStyle(messageFont: font.bodyText,
                                               messageColor: color.baseDark,
                                               backgroundColor: Color.lightGrey)
        return ChatStyle(header: header,
                         queue: queue,
                         sentMessage: sentMessage,
                         receivedMessage: receivedMessage,
                         backgroundColor: color.background)
    }()

    public init(colorStyle: ThemeColorStyle = .default,
                fontStyle: ThemeFontStyle = .default) {
        self.color = colorStyle.color
        self.font = fontStyle.font
    }
}
