extension Theme {
    var callStyle: CallStyle {
        typealias Call = L10n.Call

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
        let queue = ConnectStatusStyle(firstText: Call.Connect.Queue.firstText,
                                       firstTextFont: font.header1,
                                       firstTextFontColor: color.baseLight,
                                       secondText: Call.Connect.Queue.secondText,
                                       secondTextFont: font.subtitle,
                                       secondTextFontColor: color.baseLight)
        let connecting = ConnectStatusStyle(firstText: Call.Connect.Connecting.firstText,
                                            firstTextFont: font.header2,
                                            firstTextFontColor: color.baseLight,
                                            secondText: Call.Connect.Connecting.secondText,
                                            secondTextFont: font.header2,
                                            secondTextFontColor: color.baseLight)
        let connected = ConnectStatusStyle(firstText: Call.Connect.Connected.firstText,
                                           firstTextFont: font.header1,
                                           firstTextFontColor: color.baseLight,
                                           secondText: Call.Connect.Connected.secondText,
                                           secondTextFont: font.subtitle,
                                           secondTextFontColor: color.baseLight)
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
    }
}
