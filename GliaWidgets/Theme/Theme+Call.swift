extension Theme {
    var callStyle: CallStyle {
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
                                       firstTextFontColor: color.baseLight,
                                       secondText: Connect.Queue.secondText,
                                       secondTextFont: font.subtitle,
                                       secondTextFontColor: color.baseLight)
        let connecting = ConnectStatusStyle(firstText: Connect.Connecting.firstText,
                                            firstTextFont: font.header2,
                                            firstTextFontColor: color.baseLight,
                                            secondText: Connect.Connecting.secondText,
                                            secondTextFont: font.header2,
                                            secondTextFontColor: color.baseLight)
        let connected = ConnectStatusStyle(firstText: Connect.Connected.firstText,
                                           firstTextFont: font.header1,
                                           firstTextFontColor: color.baseLight,
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
                         videoTitle: Call.Video.title,
                         operatorNameFont: font.header1,
                         operatorNameColor: color.baseLight,
                         durationFont: font.bodyText,
                         durationColor: color.baseLight)
    }
}
