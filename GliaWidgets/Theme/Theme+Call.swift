import UIKit

extension Theme {
    var callStyle: CallStyle {
        typealias Call = L10n.Call
        let backButton = HeaderButtonStyle(
            image: Asset.back,
            color: color.baseLight
        )
        let closeButton = HeaderButtonStyle(
            image: Asset.close,
            color: color.baseLight
        )
        let endButton = ActionButtonStyle(
            title: Call.EndButton.title,
            titleFont: font.buttonLabel,
            titleColor: color.baseLight,
            backgroundColor: color.systemNegative
        )
        let endScreenShareButton = HeaderButtonStyle(
            image: Asset.startScreenShare,
            color: color.secondary
        )
        let header = HeaderStyle(
            titleFont: font.header2,
            titleColor: color.baseLight,
            backgroundColor: .clear,
            backButton: backButton,
            closeButton: closeButton,
            endButton: endButton,
            endScreenShareButton: endScreenShareButton
        )
        let operatorImage = UserImageStyle(
            placeholderImage: Asset.operatorPlaceholder,
            placeholderColor: color.baseLight,
            placeholderBackgroundColor: color.primary,
            imageBackgroundColor: .clear
        )
        let queueOperator = ConnectOperatorStyle(
            operatorImage: operatorImage,
            animationColor: .lightGray
        )
        let queue = ConnectStatusStyle(
            firstText: Call.Connect.Queue.firstText,
            firstTextFont: font.header1,
            firstTextFontColor: color.baseLight,
            secondText: Call.Connect.Queue.secondText,
            secondTextFont: font.subtitle,
            secondTextFontColor: color.baseLight
        )
        let connecting = ConnectStatusStyle(
            firstText: Call.Connect.Connecting.firstText,
            firstTextFont: font.header2,
            firstTextFontColor: color.baseLight,
            secondText: Call.Connect.Connecting.secondText,
            secondTextFont: font.header2,
            secondTextFontColor: color.baseLight
        )
        let connected = ConnectStatusStyle(
            firstText: Call.Connect.Connected.firstText,
            firstTextFont: font.header1,
            firstTextFontColor: color.baseLight,
            secondText: Call.Connect.Connected.secondText,
            secondTextFont: font.subtitle,
            secondTextFontColor: color.baseLight
        )
        let connect = ConnectStyle(
            queueOperator: queueOperator,
            queue: queue,
            connecting: connecting,
            connected: connected
        )
        return CallStyle(
            header: header,
            connect: connect,
            backgroundColor: .clear,
            preferredStatusBarStyle: .lightContent,
            audioTitle: Call.Audio.title,
            videoTitle: Call.Video.title,
            operatorName: Call.Operator.name,
            operatorNameFont: font.header1,
            operatorNameColor: color.baseLight,
            durationFont: font.bodyText,
            durationColor: color.baseLight,
            topText: Call.topText,
            topTextFont: font.subtitle,
            topTextColor: color.baseLight,
            bottomText: Call.bottomText,
            bottomTextFont: font.bodyText,
            bottomTextColor: color.baseLight,
            buttonBar: buttonBarStyle
        )
    }

    private var buttonBarStyle: CallButtonBarStyle {
        typealias Buttons = L10n.Call.Buttons

        let activeBackgroundColor = UIColor.white.withAlphaComponent(0.9)
        let inactiveBackgroundColor = UIColor.black.withAlphaComponent(0.4)
        let activeImageColor = color.baseDark
        let inactiveImageColor = color.baseLight
        let activeTitleFont = font.caption
        let inactiveTitleFont = font.caption
        let activeTitleColor = color.baseLight
        let inactiveTitleColor = color.baseLight

        let chatButton = CallButtonStyle(
            active: CallButtonStyle.StateStyle(
                backgroundColor: activeBackgroundColor,
                image: Asset.callChat,
                imageColor: activeImageColor,
                title: Buttons.Chat.title,
                titleFont: activeTitleFont,
                titleColor: activeTitleColor
            ),
            inactive: CallButtonStyle.StateStyle(
                backgroundColor: inactiveBackgroundColor,
                image: Asset.callChat,
                imageColor: inactiveImageColor,
                title: Buttons.Chat.title,
                titleFont: inactiveTitleFont,
                titleColor: inactiveTitleColor
            )
        )
        let videoButton = CallButtonStyle(
            active: CallButtonStyle.StateStyle(
                backgroundColor: activeBackgroundColor,
                image: Asset.callVideoActive,
                imageColor: activeImageColor,
                title: Buttons.Video.title,
                titleFont: activeTitleFont,
                titleColor: activeTitleColor
            ),
            inactive: CallButtonStyle.StateStyle(
                backgroundColor: inactiveBackgroundColor,
                image: Asset.callVideoInactive,
                imageColor: inactiveImageColor,
                title: Buttons.Video.title,
                titleFont: inactiveTitleFont,
                titleColor: inactiveTitleColor
            )
        )
        let muteButton = CallButtonStyle(
            active: CallButtonStyle.StateStyle(
                backgroundColor: activeBackgroundColor,
                image: Asset.callMuteActive,
                imageColor: activeImageColor,
                title: Buttons.Mute.Active.title,
                titleFont: activeTitleFont,
                titleColor: activeTitleColor
            ),
            inactive: CallButtonStyle.StateStyle(
                backgroundColor: inactiveBackgroundColor,
                image: Asset.callMuteInactive,
                imageColor: inactiveImageColor,
                title: Buttons.Mute.Inactive.title,
                titleFont: inactiveTitleFont,
                titleColor: inactiveTitleColor
            )
        )
        let speakerButton = CallButtonStyle(
            active: CallButtonStyle.StateStyle(
                backgroundColor: activeBackgroundColor,
                image: Asset.callSpeakerActive,
                imageColor: activeImageColor,
                title: Buttons.Speaker.title,
                titleFont: activeTitleFont,
                titleColor: activeTitleColor
            ),
            inactive: CallButtonStyle.StateStyle(
                backgroundColor: inactiveBackgroundColor,
                image: Asset.callSpeakerInactive,
                imageColor: inactiveImageColor,
                title: Buttons.Speaker.title,
                titleFont: inactiveTitleFont,
                titleColor: inactiveTitleColor
            )
        )
        let minimizeButton = CallButtonStyle(
            active: CallButtonStyle.StateStyle(
                backgroundColor: activeBackgroundColor,
                image: Asset.callMiminize,
                imageColor: activeImageColor,
                title: Buttons.Minimize.title,
                titleFont: activeTitleFont,
                titleColor: activeTitleColor
            ),
            inactive: CallButtonStyle.StateStyle(
                backgroundColor: inactiveBackgroundColor,
                image: Asset.callMiminize,
                imageColor: inactiveImageColor,
                title: Buttons.Minimize.title,
                titleFont: inactiveTitleFont,
                titleColor: inactiveTitleColor
            )
        )
        let badge = BadgeStyle(
            font: font.caption,
            fontColor: color.baseLight,
            backgroundColor: color.primary
        )
        return CallButtonBarStyle(
            chatButton: chatButton,
            videoButton: videoButton,
            muteButton: muteButton,
            speakerButton: speakerButton,
            minimizeButton: minimizeButton,
            badge: badge
        )
    }
}
