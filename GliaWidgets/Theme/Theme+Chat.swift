extension Theme {
    var chatStyle: ChatStyle {
        typealias Chat = L10n.Chat

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
        let queue = ConnectStatusStyle(firstText: Chat.Connect.Queue.firstText,
                                       firstTextFont: font.header1,
                                       firstTextFontColor: color.baseDark,
                                       secondText: Chat.Connect.Queue.secondText,
                                       secondTextFont: font.subtitle,
                                       secondTextFontColor: color.baseNormal)
        let connecting = ConnectStatusStyle(firstText: Chat.Connect.Connecting.firstText,
                                            firstTextFont: font.header2,
                                            firstTextFontColor: color.baseDark,
                                            secondText: Chat.Connect.Connecting.secondText,
                                            secondTextFont: font.header2,
                                            secondTextFontColor: color.baseDark)
        let connected = ConnectStatusStyle(firstText: Chat.Connect.Connected.firstText,
                                           firstTextFont: font.header1,
                                           firstTextFontColor: color.baseDark,
                                           secondText: Chat.Connect.Connected.secondText,
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
        let userImage = UserImageStyle(placeholderImage: Asset.operatorPlaceholder.image,
                                       placeholderColor: color.baseLight,
                                       backgroundColor: color.primary)
        let callBubble = BubbleStyle(userImage: userImage)
        return ChatStyle(header: header,
                         connect: connect,
                         backgroundColor: color.background,
                         endButton: endButton,
                         preferredStatusBarStyle: .lightContent,
                         title: Chat.title,
                         visitorMessage: visitorMessage,
                         operatorMessage: operatorMessage,
                         messageEntry: messageEntry,
                         callBubble: callBubble)
    }
}
