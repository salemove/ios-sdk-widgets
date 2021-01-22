import UIKit

public class Theme {
    private typealias Strings = L10n

    public let color: ThemeColor
    public let font: ThemeFont

    public lazy var chat: ChatStyle = {
        typealias Chat = L10n.Chat
        typealias Connect = L10n.Connect

        let header = HeaderStyle(titleFont: font.header2,
                                 titleColor: color.baseLight,
                                 leftItemColor: color.baseLight,
                                 rightItemColor: color.baseLight,
                                 backgroundColor: color.primary)

        let operatorImage = UserImageStyle(placeholderImage: Asset.operatorPlaceholder.image,
                                           placeholderColor: color.baseLight,
                                           backgroundColor: color.primary)
        let queueOperator = ConnectOperatorStyle(operatorImage: operatorImage,
                                                 animationColor: color.primary)
        let queue = ConnectStatusStyle(firstText: Connect.Queue.firstText,
                                       firstTextFont: font.header1,
                                       firstTextFontColor: color.baseDark,
                                       secondText: Connect.Queue.secondText,
                                       secondTextFont: font.subtitle,
                                       secondTextFontColor: color.baseNormal)
        let connecting = ConnectStatusStyle(firstText: Connect.Connecting.firstText,
                                            firstTextFont: font.header2,
                                            firstTextFontColor: color.baseDark,
                                            secondText: Connect.Connecting.secondText,
                                            secondTextFont: font.header2,
                                            secondTextFontColor: color.baseDark)
        let connected = ConnectStatusStyle(firstText: Connect.Connected.firstText,
                                           firstTextFont: font.header1,
                                           firstTextFontColor: color.baseDark,
                                           secondText: Connect.Connected.secondText,
                                           secondTextFont: font.subtitle,
                                           secondTextFontColor: color.primary)
        let connect = ConnectStyle(queueOperator: queueOperator,
                                   queue: queue,
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
                         connect: connect,
                         backgroundColor: color.background,
                         endButton: endButton,
                         preferredStatusBarStyle: .lightContent,
                         title: Chat.title,
                         visitorMessage: visitorMessage,
                         operatorMessage: operatorMessage,
                         messageEntry: messageEntry)
    }()

    public lazy var call: CallStyle = {
        typealias Call = L10n.Call
        typealias Connect = L10n.Connect

        let header = HeaderStyle(titleFont: font.subtitle,
                                 titleColor: color.baseLight,
                                 leftItemColor: color.baseLight,
                                 rightItemColor: color.baseLight,
                                 backgroundColor: .clear)

        let operatorImage = UserImageStyle(placeholderImage: Asset.operatorPlaceholder.image,
                                           placeholderColor: color.baseLight,
                                           backgroundColor: color.primary)
        let queueOperator = ConnectOperatorStyle(operatorImage: operatorImage,
                                                 animationColor: .lightGray)
        let queue = ConnectStatusStyle(firstText: Connect.Queue.firstText,
                                       firstTextFont: font.header1,
                                       firstTextFontColor: color.baseDark,
                                       secondText: Connect.Queue.secondText,
                                       secondTextFont: font.subtitle,
                                       secondTextFontColor: color.baseNormal)
        let connecting = ConnectStatusStyle(firstText: Connect.Connecting.firstText,
                                            firstTextFont: font.header2,
                                            firstTextFontColor: color.baseDark,
                                            secondText: Connect.Connecting.secondText,
                                            secondTextFont: font.header2,
                                            secondTextFontColor: color.baseDark)
        let connected = ConnectStatusStyle(firstText: Connect.Connected.firstText,
                                           firstTextFont: font.header1,
                                           firstTextFontColor: color.baseDark,
                                           secondText: Connect.Connected.secondText,
                                           secondTextFont: font.subtitle,
                                           secondTextFontColor: color.primary)
        let connect = ConnectStyle(queueOperator: queueOperator,
                                   queue: queue,
                                   connecting: connecting,
                                   connected: connected)

        let endButton = ActionButtonStyle(title: Call.EndButton.title,
                                          titleFont: font.buttonLabel,
                                          titleColor: color.baseLight,
                                          backgroundColor: color.systemNegative)
        return CallStyle(header: header,
                         connect: connect,
                         backgroundColor: .clear,
                         endButton: endButton,
                         preferredStatusBarStyle: .lightContent,
                         audioTitle: Call.Audio.title,
                         videoTitle: Call.Video.title)
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
                          titleImageColor: color.primary,
                          messageFont: font.bodyText,
                          messageColor: color.baseDark,
                          backgroundColor: color.background,
                          closeButtonColor: color.baseNormal,
                          positiveAction: positiveAction,
                          negativeAction: negativeAction)
    }()

    public lazy var alertConf: AlertConf = {
        typealias Alert = L10n.Alert

        let leaveQueue = ConfirmationAlertConf(title: Alert.LeaveQueue.title,
                                               message: Alert.LeaveQueue.message,
                                               negativeTitle: Alert.Action.no,
                                               positiveTitle: Alert.Action.yes)
        let endEngagement = ConfirmationAlertConf(title: Alert.EndEngagement.title,
                                                  message: Alert.EndEngagement.message,
                                                  negativeTitle: Alert.Action.no,
                                                  positiveTitle: Alert.Action.yes)
        let operatorsUnavailable = MessageAlertConf(title: Alert.OperatorsUnavailable.title,
                                                    message: Alert.OperatorsUnavailable.message)
        let audioAction = MediaUpgradeActionStyle(title: Alert.MediaUpgrade.Audio.title,
                                                  titleFont: font.header3,
                                                  titleColor: color.baseDark,
                                                  info: Alert.MediaUpgrade.Audio.info,
                                                  infoFont: font.subtitle,
                                                  infoColor: color.baseDark,
                                                  borderColor: color.primary,
                                                  backgroundColor: color.background,
                                                  icon: Asset.upgradeAudio.image,
                                                  iconColor: color.primary)
        let phoneAction = MediaUpgradeActionStyle(title: Alert.MediaUpgrade.Phone.title,
                                                  titleFont: font.header3,
                                                  titleColor: color.baseDark,
                                                  info: Alert.MediaUpgrade.Phone.info,
                                                  infoFont: font.subtitle,
                                                  infoColor: color.baseDark,
                                                  borderColor: color.primary,
                                                  backgroundColor: color.background,
                                                  icon: Asset.upgradePhone.image,
                                                  iconColor: color.primary)
        let mediaUpgrade = MediaUpgradeAlertConf(title: Alert.MediaUpgrade.title,
                                                 audioUpgradeAction: audioAction,
                                                 phoneUpgradeAction: phoneAction)
        let audioUpgrade = AudioUpgradeAlertConf(title: Alert.AudioUpgrade.title,
                                                 titleImage: Asset.upgradeAudio.image,
                                                 decline: Alert.Action.decline,
                                                 accept: Alert.Action.accept)
        let unexpected = MessageAlertConf(title: Alert.Unexpected.title,
                                          message: Alert.Unexpected.message)
        let api = MessageAlertConf(title: Alert.ApiError.title,
                                   message: Alert.ApiError.message)

        return AlertConf(leaveQueue: leaveQueue,
                        endEngagement: endEngagement,
                        operatorsUnavailable: operatorsUnavailable,
                        mediaUpgrade: mediaUpgrade,
                        audioUpgrade: audioUpgrade,
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
