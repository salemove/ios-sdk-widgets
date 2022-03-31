import UIKit

extension Theme {
    var callStyle: CallStyle {
        typealias Call = L10n.Call
        typealias Accessibility = Call.Accessibility
        let backButton = HeaderButtonStyle(
            image: Asset.back.image,
            color: color.baseLight,
            accessibility: .init(
                label: Accessibility.Header.BackButton.label,
                hint: Accessibility.Header.BackButton.hint
            )
        )
        let closeButton = HeaderButtonStyle(
            image: Asset.close.image,
            color: color.baseLight,
            accessibility: .init(
                label: Accessibility.Header.CloseButton.label,
                hint: Accessibility.Header.CloseButton.hint
            )
        )
        let endButton = ActionButtonStyle(
            title: Call.EndButton.title,
            titleFont: font.buttonLabel,
            titleColor: color.baseLight,
            backgroundColor: color.systemNegative,
            accessibility: .init(label: Accessibility.Header.EndButton.label)
        )
        let endScreenShareButton = HeaderButtonStyle(
            image: Asset.startScreenShare.image,
            color: color.secondary,
            accessibility: .init(
                label: Accessibility.Header.EndScreenShareButton.label,
                hint: Accessibility.Header.EndScreenShareButton.hint
            )
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
            placeholderImage: Asset.operatorPlaceholder.image,
            placeholderColor: color.baseLight,
            placeholderBackgroundColor: color.primary,
            imageBackgroundColor: .clear
        )
        let queueOperator = ConnectOperatorStyle(
            operatorImage: operatorImage,
            animationColor: .lightGray,
            accessibility: .init(
                label: Accessibility.Operator.Avatar.label,
                hint: Accessibility.Operator.Avatar.hint
            )
        )
        let queue = ConnectStatusStyle(
            firstText: Call.Connect.Queue.firstText,
            firstTextFont: font.header1,
            firstTextFontColor: color.baseLight,
            secondText: Call.Connect.Queue.secondText,
            secondTextFont: font.subtitle,
            secondTextFontColor: color.baseLight,
            accessibility: .init(
                firstTextHint: Accessibility.Connect.Queue.FirstText.hint,
                secondTextHint: Accessibility.Connect.Queue.SecondText.hint
            )
        )
        let connecting = ConnectStatusStyle(
            firstText: Call.Connect.Connecting.firstText,
            firstTextFont: font.header2,
            firstTextFontColor: color.baseLight,
            secondText: Call.Connect.Connecting.secondText,
            secondTextFont: font.header2,
            secondTextFontColor: color.baseLight,
            accessibility: .init(
                firstTextHint: Accessibility.Connect.Connecting.FirstText.hint,
                secondTextHint: Accessibility.Connect.Connecting.SecondText.hint
            )
        )
        let connected = ConnectStatusStyle(
            firstText: Call.Connect.Connected.firstText,
            firstTextFont: font.header1,
            firstTextFontColor: color.baseLight,
            secondText: Call.Connect.Connected.secondText,
            secondTextFont: font.subtitle,
            secondTextFontColor: color.baseLight,
            accessibility: .init(
                firstTextHint: Accessibility.Connect.Connected.FirstText.hint,
                secondTextHint: Accessibility.Connect.Connected.SecondText.hint
            )
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
            buttonBar: buttonBarStyle,
            accessibility: .init(
                operatorNameHint: Accessibility.OperatorName.hint,
                durationHint: Accessibility.CallDuration.hint,
                localVideoLabel: Accessibility.Video.Visitor.label,
                remoteVideoLabel: Accessibility.Video.Operator.label
            )
        )
    }

    private var buttonBarStyle: CallButtonBarStyle {
        typealias Buttons = L10n.Call.Buttons
        typealias Accessibility = L10n.Call.Accessibility

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
                image: Asset.callChat.image,
                imageColor: activeImageColor,
                title: Buttons.Chat.title,
                titleFont: activeTitleFont,
                titleColor: activeTitleColor,
                accessibility: .init(
                    label: Accessibility.Buttons.Chat.Active.label
                )
            ),
            inactive: CallButtonStyle.StateStyle(
                backgroundColor: inactiveBackgroundColor,
                image: Asset.callChat.image,
                imageColor: inactiveImageColor,
                title: Buttons.Chat.title,
                titleFont: inactiveTitleFont,
                titleColor: inactiveTitleColor,
                accessibility: .init(
                    label: Accessibility.Buttons.Chat.Inactive.label
                )
            ),
            accessibility: .init(
                singleItemBadgeValue: Accessibility.Buttons.Chat.BadgeValue.singleItem,
                multipleItemsBadgeValue: Accessibility.Buttons.Chat.BadgeValue.multipleItems,
                titleAndBadgeValue: Accessibility.Buttons.Chat.titleAndBadgeValue
            )
        )
        let videoButton = CallButtonStyle(
            active: CallButtonStyle.StateStyle(
                backgroundColor: activeBackgroundColor,
                image: Asset.callVideoActive.image,
                imageColor: activeImageColor,
                title: Buttons.Video.title,
                titleFont: activeTitleFont,
                titleColor: activeTitleColor,
                accessibility: .init(
                    label: Accessibility.Buttons.Video.Active.label
                )
            ),
            inactive: CallButtonStyle.StateStyle(
                backgroundColor: inactiveBackgroundColor,
                image: Asset.callVideoInactive.image,
                imageColor: inactiveImageColor,
                title: Buttons.Video.title,
                titleFont: inactiveTitleFont,
                titleColor: inactiveTitleColor,
                accessibility: .init(
                    label: Accessibility.Buttons.Video.Inactive.label
                )
            ),
            accessibility: .init(
                singleItemBadgeValue: Accessibility.Buttons.Video.BadgeValue.singleItem,
                multipleItemsBadgeValue: Accessibility.Buttons.Video.BadgeValue.multipleItems,
                titleAndBadgeValue: Accessibility.Buttons.Video.titleAndBadgeValue
            )
        )
        let muteButton = CallButtonStyle(
            active: CallButtonStyle.StateStyle(
                backgroundColor: activeBackgroundColor,
                image: Asset.callMuteActive.image,
                imageColor: activeImageColor,
                title: Buttons.Mute.Active.title,
                titleFont: activeTitleFont,
                titleColor: activeTitleColor,
                accessibility: .init(
                    label: Accessibility.Buttons.Mute.Active.label
                )
            ),
            inactive: CallButtonStyle.StateStyle(
                backgroundColor: inactiveBackgroundColor,
                image: Asset.callMuteInactive.image,
                imageColor: inactiveImageColor,
                title: Buttons.Mute.Inactive.title,
                titleFont: inactiveTitleFont,
                titleColor: inactiveTitleColor,
                accessibility: .init(
                    label: Accessibility.Buttons.Mute.Inactive.label
                )
            ),
            accessibility: .init(
                singleItemBadgeValue: Accessibility.Buttons.Mute.BadgeValue.singleItem,
                multipleItemsBadgeValue: Accessibility.Buttons.Mute.BadgeValue.multipleItems,
                titleAndBadgeValue: Accessibility.Buttons.Mute.titleAndBadgeValue
            )
        )
        let speakerButton = CallButtonStyle(
            active: CallButtonStyle.StateStyle(
                backgroundColor: activeBackgroundColor,
                image: Asset.callSpeakerActive.image,
                imageColor: activeImageColor,
                title: Buttons.Speaker.title,
                titleFont: activeTitleFont,
                titleColor: activeTitleColor,
                accessibility: .init(
                    label: Accessibility.Buttons.Speaker.Active.label
                )
            ),
            inactive: CallButtonStyle.StateStyle(
                backgroundColor: inactiveBackgroundColor,
                image: Asset.callSpeakerInactive.image,
                imageColor: inactiveImageColor,
                title: Buttons.Speaker.title,
                titleFont: inactiveTitleFont,
                titleColor: inactiveTitleColor,
                accessibility: .init(
                    label: Accessibility.Buttons.Speaker.Inactive.label
                )
            ),
            accessibility: .init(
                singleItemBadgeValue: Accessibility.Buttons.Speaker.BadgeValue.singleItem,
                multipleItemsBadgeValue: Accessibility.Buttons.Speaker.BadgeValue.multipleItems,
                titleAndBadgeValue: Accessibility.Buttons.Speaker.titleAndBadgeValue
            )
        )
        let minimizeButton = CallButtonStyle(
            active: CallButtonStyle.StateStyle(
                backgroundColor: activeBackgroundColor,
                image: Asset.callMiminize.image,
                imageColor: activeImageColor,
                title: Buttons.Minimize.title,
                titleFont: activeTitleFont,
                titleColor: activeTitleColor,
                accessibility: .init(
                    label: Accessibility.Buttons.Minimize.Active.label
                )
            ),
            inactive: CallButtonStyle.StateStyle(
                backgroundColor: inactiveBackgroundColor,
                image: Asset.callMiminize.image,
                imageColor: inactiveImageColor,
                title: Buttons.Minimize.title,
                titleFont: inactiveTitleFont,
                titleColor: inactiveTitleColor,
                accessibility: .init(
                    label: Accessibility.Buttons.Minimize.Inactive.label
                )
            ),
            accessibility: .init(
                singleItemBadgeValue: Accessibility.Buttons.Minimize.BadgeValue.singleItem,
                multipleItemsBadgeValue: Accessibility.Buttons.Minimize.BadgeValue.multipleItems,
                titleAndBadgeValue: Accessibility.Buttons.Minimize.titleAndBadgeValue
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
