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
        let waiting = QueueStatusStyle(firstText: Queue.Waiting.firstText,
                                       firstTextFont: font.header1,
                                       firstTextFontColor: color.baseDark,
                                       secondText: Queue.Waiting.secondText,
                                       secondTextFont: font.subtitle,
                                       secondTextFontColor: color.baseNormal)
        let connecting = QueueStatusStyle(firstText: Queue.Connecting.firstText,
                                          firstTextFont: font.header2,
                                          firstTextFontColor: color.baseDark,
                                          secondText: Queue.Connecting.secondText,
                                          secondTextFont: font.header2,
                                          secondTextFontColor: color.baseDark)
        let connected = QueueStatusStyle(firstText: Queue.Connected.firstText,
                                         firstTextFont: font.header1,
                                         firstTextFontColor: color.baseDark,
                                         secondText: Queue.Connected.secondText,
                                         secondTextFont: font.subtitle,
                                         secondTextFontColor: color.primary)
        let queue = QueueStyle(queueOperator: queueOperator,
                               waiting: waiting,
                               connecting: connecting,
                               connected: connected)

        let visitorMessage = VisitorChatMessageStyle(messageFont: font.bodyText,
                                                     messageColor: color.baseLight,
                                                     backgroundColor: color.primary,
                                                     statusFont: font.caption,
                                                     statusColor: color.baseNormal,
                                                     delivered: Chat.Message.Status.delivered)
        let operatorMessage = OperatorChatMessageStyle(messageFont: font.bodyText,
                                                       messageColor: color.baseDark,
                                                       backgroundColor: Color.lightGrey,
                                                       operatorImage: operatorImage)
        let endButton = ActionButtonStyle(title: Chat.EndButton.title,
                                          titleFont: font.buttonLabel,
                                          titleColor: color.baseLight,
                                          backgroundColor: color.systemNegative)
        let messageEntry = ChatMessageEntryStyle(messageFont: font.bodyText,
                                                 messageColor: color.baseDark,
                                                 placeholder: Chat.Message.placeholder,
                                                 placeholderFont: font.bodyText,
                                                 placeholderColor: color.baseNormal,
                                                 sendButtonColor: color.primary,
                                                 separatorColor: color.baseShade,
                                                 backgroundColor: color.background)
        return ChatStyle(header: header,
                         queue: queue,
                         visitorMessage: visitorMessage,
                         operatorMessage: operatorMessage,
                         backgroundColor: color.background,
                         endButton: endButton,
                         messageEntry: messageEntry,
                         preferredStatusBarStyle: .lightContent)
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

    public lazy var minimizedBubble: BubbleStyle = {
        let userImage = UserImageStyle(placeholderImage: Asset.operatorPlaceholder.image,
                                       placeholderColor: color.baseLight,
                                       backgroundColor: color.primary)
        return BubbleStyle(userImage: userImage)
    }()

    public init(colorStyle: ThemeColorStyle = .default,
                fontStyle: ThemeFontStyle = .default) {
        self.color = colorStyle.color
        self.font = fontStyle.font
    }
}
