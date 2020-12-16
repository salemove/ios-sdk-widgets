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

        let operatorImage = UserImageStyle(placeholderImage: Asset.operatorPlaceholder.image,
                                           placeholderColor: color.baseLight,
                                           backgroundColor: color.primary)
        let queueOperator = QueueOperatorStyle(operatorImage: operatorImage,
                                               animationColor: color.primary)
        let waiting = QueueStatusStyle(text1: Queue.Waiting.text1,
                                       text1Font: font.header1,
                                       text1FontColor: color.baseDark,
                                       text2: Queue.Waiting.text2,
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
                               waiting: waiting,
                               connecting: connecting,
                               connected: connected)

        let sentMessage = ChatMessageStyle(messageFont: font.bodyText,
                                           messageColor: color.baseLight,
                                           backgroundColor: color.primary)
        let receivedMessage = ChatMessageStyle(messageFont: font.bodyText,
                                               messageColor: color.baseDark,
                                               backgroundColor: Color.lightGrey)
        let endButton = ActionButtonStyle(title: Chat.EndButton.title,
                                          titleFont: font.buttonLabel,
                                          titleColor: color.baseLight,
                                          backgroundColor: color.systemNegative)
        return ChatStyle(header: header,
                         queue: queue,
                         sentMessage: sentMessage,
                         receivedMessage: receivedMessage,
                         backgroundColor: color.background,
                         endButton: endButton)
    }()

    public lazy var alert: AlertStyle = {
        typealias Alert = L10n.Alert

        let negativeAction = ActionButtonStyle(title: Alert.Action.no,
                                               titleFont: font.buttonLabel,
                                               titleColor: color.baseLight,
                                               backgroundColor: color.primary)
        let positiveAction = ActionButtonStyle(title: Alert.Action.yes,
                                               titleFont: font.buttonLabel,
                                               titleColor: color.baseLight,
                                               backgroundColor: color.systemNegative)
        return AlertStyle(titleFont: font.header2,
                          titleColor: color.baseDark,
                          messageFont: font.bodyText,
                          messageColor: color.baseDark,
                          backgroundColor: color.background,
                          closeButtonColor: color.baseNormal,
                          positiveAction: positiveAction,
                          negativeAction: negativeAction)
    }()

    public lazy var alertStrings: AlertStrings = {
        typealias Alert = L10n.Alert

        let leaveQueue = AlertConfirmationStrings(title: Alert.LeaveQueue.title,
                                                  message: Alert.LeaveQueue.message,
                                                  negativeTitle: Alert.Action.no,
                                                  positiveTitle: Alert.Action.yes)
        let endEngagement = AlertConfirmationStrings(title: Alert.EndEngagement.title,
                                                     message: Alert.EndEngagement.message,
                                                     negativeTitle: Alert.Action.no,
                                                     positiveTitle: Alert.Action.yes)
        let operatorsUnavailable = AlertMessageStrings(title: Alert.OperatorsUnavailable.title,
                                                       message: Alert.OperatorsUnavailable.message)
        let unexpected = AlertMessageStrings(title: Alert.Unexpected.title,
                                             message: Alert.Unexpected.message)
        let api = AlertMessageStrings(title: Alert.ApiError.title,
                                      message: Alert.ApiError.message)

        return AlertStrings(leaveQueue: leaveQueue,
                            endEngagement: endEngagement,
                            operatorsUnavailable: operatorsUnavailable,
                            unexpectedError: unexpected,
                            apiError: api)
    }()

    public lazy var minimizedOperator: UserImageStyle = {
        return UserImageStyle(placeholderImage: Asset.operatorPlaceholder.image,
                              placeholderColor: color.baseLight,
                              backgroundColor: color.primary)
    }()

    public init(colorStyle: ThemeColorStyle = .default,
                fontStyle: ThemeFontStyle = .default) {
        self.color = colorStyle.color
        self.font = fontStyle.font
    }
}
