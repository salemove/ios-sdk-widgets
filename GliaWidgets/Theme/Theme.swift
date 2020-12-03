import UIKit

public class Theme {
    private typealias Strings = L10n

    public let color: ThemeColor
    public let font: ThemeFont

    public lazy var chat: ChatStyle = {
        typealias Strings = L10n.Chat

        let header = HeaderStyle(title: Strings.title,
                                 titleFont: font.header2,
                                 titleColor: color.baseLight,
                                 leftItemColor: color.baseLight,
                                 rightItemColor: color.baseLight,
                                 backgroundColor: color.primary)

        let queueOperator = QueueOperatorStyle(placeholderImage: Asset.chatOperatorPlaceholder.image,
                                               placeholderColor: color.baseLight,
                                               animationColor: color.primary)
        let enqueued = QueueStatusStyle(text1: Strings.Operator.Enqueued.text1,
                                        text1Font: font.header1,
                                        text1FontColor: color.baseDark,
                                        text2: Strings.Operator.Enqueued.text2,
                                        text2Font: font.subtitle,
                                        text2FontColor: color.baseNormal)
        let connecting = QueueStatusStyle(text1: Strings.Operator.Connecting.text1,
                                          text1Font: font.header2,
                                          text1FontColor: color.baseDark,
                                          text2: Strings.Operator.Connecting.text2,
                                          text2Font: font.header2,
                                          text2FontColor: color.baseDark)
        let connected = QueueStatusStyle(text1: Strings.Operator.Connected.text1,
                                         text1Font: font.header1,
                                         text1FontColor: color.baseDark,
                                         text2: Strings.Operator.Connected.text2,
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
