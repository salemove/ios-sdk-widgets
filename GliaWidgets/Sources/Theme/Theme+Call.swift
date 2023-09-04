import UIKit

extension Theme {
    var callStyle: CallStyle {
        let onHoldOverlay = OnHoldOverlayStyle(
            image: Asset.callOnHold.image,
            imageColor: .fill(color: .white),
            imageSize: .init(width: 40, height: 40)
        )
        let backButton = HeaderButtonStyle(
            image: Asset.back.image,
            color: color.baseLight,
            accessibility: .init(
                label: Localization.General.back,
                hint: Localization.Call.Header.Back.Button.Accessibility.hint
            )
        )
        let closeButton = HeaderButtonStyle(
            image: Asset.close.image,
            color: color.baseLight,
            accessibility: .init(
                label: Localization.General.close,
                hint: ""
            )
        )
        let endButton = ActionButtonStyle(
            title: Localization.General.end,
            titleFont: font.buttonLabel,
            titleColor: color.baseLight,
            backgroundColor: .fill(color: color.systemNegative),
            accessibility: .init(
                label: Localization.General.end,
                isFontScalingEnabled: true
            )
        )
        let endScreenShareButton = HeaderButtonStyle(
            image: Asset.startScreenShare.image,
            color: color.baseLight,
            accessibility: .init(
                label: Localization.General.end,
                hint: ""
            )
        )
        let header = HeaderStyle(
            titleFont: font.header2,
            titleColor: color.baseLight,
            backgroundColor: .fill(color: .clear),
            backButton: backButton,
            closeButton: closeButton,
            endButton: endButton,
            endScreenShareButton: endScreenShareButton,
            accessibility: .init(isFontScalingEnabled: true)
        )
        let operatorImage = UserImageStyle(
            placeholderImage: Asset.operatorPlaceholder.image,
            placeholderColor: color.baseLight,
            placeholderBackgroundColor: .fill(color: color.primary),
            imageBackgroundColor: .fill(color: .clear),
            transferringImage: Asset.operatorTransferring.image
        )
        let queueOperator = ConnectOperatorStyle(
            operatorImage: operatorImage,
            animationColor: .lightGray,
            onHoldOverlay: onHoldOverlay,
            accessibility: .init(
                label: Localization.Call.Operator.Avatar.Accessibility.label,
                hint: Localization.Call.Operator.Avatar.Accessibility.hint
            )
        )
        let queue = ConnectStatusStyle(
            firstText: Localization.General.companyName,
            firstTextFont: font.header1,
            firstTextFontColor: color.baseLight,
            firstTextStyle: .title1,
            secondText: Localization.Engagement.Connect.placeholder,
            secondTextFont: font.subtitle,
            secondTextFontColor: color.baseLight,
            secondTextStyle: .footnote,
            accessibility: .init(
                firstTextHint: Localization.Call.Connect.FirstText.Accessibility.hint,
                secondTextHint: nil,
                isFontScalingEnabled: true
            )
        )
        let connecting = ConnectStatusStyle(
            firstText: Localization.Engagement.Connect.with,
            firstTextFont: font.header2,
            firstTextFontColor: color.baseLight,
            firstTextStyle: .title2,
            secondText: "",
            secondTextFont: font.header2,
            secondTextFontColor: color.baseLight,
            secondTextStyle: .title2,
            accessibility: .init(
                firstTextHint: Localization.Call.Connect.FirstText.Accessibility.hint,
                secondTextHint: nil,
                isFontScalingEnabled: true
            )
        )
        let connected = ConnectStatusStyle(
            firstText: Localization.Templates.operatorName,
            firstTextFont: font.header1,
            firstTextFontColor: color.baseLight,
            firstTextStyle: .title1,
            secondText: Localization.Templates.callDuration,
            secondTextFont: font.subtitle,
            secondTextFontColor: color.baseLight,
            secondTextStyle: .footnote,
            accessibility: .init(
                firstTextHint: Localization.Call.Connect.FirstText.Accessibility.hint,
                secondTextHint: Localization.Call.Connect.SecondText.Accessibility.hint,
                isFontScalingEnabled: true
            )
        )
        let onHold = ConnectStatusStyle(
            firstText: Localization.Templates.operatorName,
            firstTextFont: font.header1,
            firstTextFontColor: color.baseLight,
            firstTextStyle: .title1,
            secondText: Localization.Templates.callDuration,
            secondTextFont: font.subtitle,
            secondTextFontColor: color.baseLight,
            secondTextStyle: .footnote,
            accessibility: .init(
                firstTextHint: Localization.Call.Connect.FirstText.Accessibility.hint,
                secondTextHint: nil,
                isFontScalingEnabled: true
            )
        )
        let transferring = ConnectStatusStyle(
            firstText: Localization.Engagement.QueueTransferring.message,
            firstTextFont: font.header1,
            firstTextFontColor: color.baseLight,
            firstTextStyle: .title1,
            secondText: nil,
            secondTextFont: font.subtitle,
            secondTextFontColor: color.baseLight,
            secondTextStyle: .footnote
        )
        let connect = ConnectStyle(
            queueOperator: queueOperator,
            queue: queue,
            connecting: connecting,
            connected: connected,
            transferring: transferring,
            onHold: onHold
        )
        let onHoldStyle = CallStyle.OnHoldStyle(
            onHoldText: Localization.Call.onHold,
            descriptionText: Localization.Call.OnHold.bottomText,
            localVideoStreamLabelText: Localization.General.you,
            localVideoStreamLabelFont: font.mediumSubtitle2,
            localVideoStreamLabelColor: color.baseLight
        )

        return CallStyle(
            header: header,
            connect: connect,
            backgroundColor: .fill(color: .white),
            preferredStatusBarStyle: .lightContent,
            audioTitle: Localization.Media.Audio.name,
            videoTitle: Localization.Media.Video.name,
            operatorName: Localization.Templates.operatorName,
            operatorNameFont: font.header1,
            operatorNameColor: color.baseLight,
            durationFont: font.bodyText,
            durationColor: color.baseLight,
            topText: Localization.Ios.Engagement.QueueWait.videoNotice,
            topTextFont: font.subtitle,
            topTextColor: color.baseLight,
            bottomText: Localization.Engagement.QueueWait.message,
            bottomTextFont: font.bodyText,
            bottomTextColor: color.baseLight,
            buttonBar: buttonBarStyle,
            onHoldStyle: onHoldStyle,
            accessibility: .init(
                operatorNameHint: Localization.Call.Connect.FirstText.Accessibility.hint,
                durationHint: Localization.Call.Connect.SecondText.Accessibility.hint,
                localVideoLabel: Localization.Call.Video.Visitor.Accessibility.label,
                remoteVideoLabel: Localization.Call.Video.Operator.Accessibility.label,
                isFontScalingEnabled: true
            )
        )
    }

    private var buttonBarStyle: CallButtonBarStyle {
        let activeBackgroundColor: ColorType = .fill(color: UIColor.white.withAlphaComponent(0.9))
        let inactiveBackgroundColor: ColorType = .fill(color: UIColor.black.withAlphaComponent(0.4))
        let activeImageColor: ColorType = .fill(color: color.baseDark)
        let inactiveImageColor: ColorType = .fill(color: color.baseLight)
        let activeTitleFont = font.caption
        let inactiveTitleFont = font.caption
        let activeTitleColor = color.baseLight
        let inactiveTitleColor = color.baseLight

        let chatButton = CallButtonStyle(
            active: CallButtonStyle.StateStyle(
                backgroundColor: activeBackgroundColor,
                image: Asset.callChat.image,
                imageColor: activeImageColor,
                title: Localization.Media.Text.name,
                titleFont: activeTitleFont,
                titleColor: activeTitleColor,
                textStyle: .caption1,
                accessibility: .init(
                    label: Localization.General.selected
                )
            ),
            inactive: CallButtonStyle.StateStyle(
                backgroundColor: inactiveBackgroundColor,
                image: Asset.callChat.image,
                imageColor: inactiveImageColor,
                title: Localization.Media.Text.name,
                titleFont: inactiveTitleFont,
                titleColor: inactiveTitleColor,
                textStyle: .caption1,
                accessibility: .init(label: "")
            ),
            selected: CallButtonStyle.StateStyle(
                backgroundColor: inactiveBackgroundColor,
                image: Asset.callChat.image,
                imageColor: inactiveImageColor,
                title: Localization.Media.Text.name,
                titleFont: inactiveTitleFont,
                titleColor: inactiveTitleColor,
                textStyle: .caption1,
                accessibility: .init(label: "")
            ),
            accessibility: .init(
                singleItemBadgeValue: Localization.Call.Buttons.Chat.BadgeValue.SingleItem.Accessibility.label,
                multipleItemsBadgeValue: Localization.Call.Buttons.Chat.BadgeValue.MultipleItems.Accessibility.label,
                titleAndBadgeValue: Localization.Templates.titleAndBadgeValue,
                isFontScalingEnabled: true
            )
        )
        let videoButton = CallButtonStyle(
            active: CallButtonStyle.StateStyle(
                backgroundColor: activeBackgroundColor,
                image: Asset.callVideoActive.image,
                imageColor: activeImageColor,
                title: Localization.Media.Video.name,
                titleFont: activeTitleFont,
                titleColor: activeTitleColor,
                textStyle: .caption1,
                accessibility: .init(
                    label: Localization.General.selected
                )
            ),
            inactive: CallButtonStyle.StateStyle(
                backgroundColor: inactiveBackgroundColor,
                image: Asset.callVideoInactive.image,
                imageColor: inactiveImageColor,
                title: Localization.Media.Video.name,
                titleFont: inactiveTitleFont,
                titleColor: inactiveTitleColor,
                textStyle: .caption1,
                accessibility: .init(label: "")
            ),
            selected: CallButtonStyle.StateStyle(
                backgroundColor: inactiveBackgroundColor,
                image: Asset.callVideoInactive.image,
                imageColor: inactiveImageColor,
                title: Localization.Media.Video.name,
                titleFont: inactiveTitleFont,
                titleColor: inactiveTitleColor,
                textStyle: .caption1,
                accessibility: .init(label: "")
            ),
            accessibility: .init(
                singleItemBadgeValue: "",
                multipleItemsBadgeValue: "",
                titleAndBadgeValue: Localization.Templates.titleAndBadgeValue,
                isFontScalingEnabled: true
            )
        )
        let muteButton = CallButtonStyle(
            active: CallButtonStyle.StateStyle(
                backgroundColor: activeBackgroundColor,
                image: Asset.callMuteActive.image,
                imageColor: activeImageColor,
                title: Localization.Call.Button.unmute,
                titleFont: activeTitleFont,
                titleColor: activeTitleColor,
                textStyle: .caption1,
                accessibility: .init(
                    label: Localization.General.selected
                )
            ),
            inactive: CallButtonStyle.StateStyle(
                backgroundColor: inactiveBackgroundColor,
                image: Asset.callMuteInactive.image,
                imageColor: inactiveImageColor,
                title: Localization.Call.Button.mute,
                titleFont: inactiveTitleFont,
                titleColor: inactiveTitleColor,
                textStyle: .caption1,
                accessibility: .init(label: "")
            ),
            selected: CallButtonStyle.StateStyle(
                backgroundColor: inactiveBackgroundColor,
                image: Asset.callMuteInactive.image,
                imageColor: inactiveImageColor,
                title: Localization.Call.Button.mute,
                titleFont: inactiveTitleFont,
                titleColor: inactiveTitleColor,
                textStyle: .caption1,
                accessibility: .init(label: "")
            ),
            accessibility: .init(
                singleItemBadgeValue: "",
                multipleItemsBadgeValue: "",
                titleAndBadgeValue: Localization.Templates.titleAndBadgeValue,
                isFontScalingEnabled: true
            )
        )
        let speakerButton = CallButtonStyle(
            active: CallButtonStyle.StateStyle(
                backgroundColor: activeBackgroundColor,
                image: Asset.callSpeakerActive.image,
                imageColor: activeImageColor,
                title: Localization.Call.Button.speaker,
                titleFont: activeTitleFont,
                titleColor: activeTitleColor,
                textStyle: .caption1,
                accessibility: .init(
                    label: Localization.General.selected
                )
            ),
            inactive: CallButtonStyle.StateStyle(
                backgroundColor: inactiveBackgroundColor,
                image: Asset.callSpeakerInactive.image,
                imageColor: inactiveImageColor,
                title: Localization.Call.Button.speaker,
                titleFont: inactiveTitleFont,
                titleColor: inactiveTitleColor,
                textStyle: .caption1,
                accessibility: .init(label: "")
            ),
            selected: CallButtonStyle.StateStyle(
                backgroundColor: inactiveBackgroundColor,
                image: Asset.callSpeakerInactive.image,
                imageColor: inactiveImageColor,
                title: Localization.Call.Button.speaker,
                titleFont: inactiveTitleFont,
                titleColor: inactiveTitleColor,
                textStyle: .caption1,
                accessibility: .init(label: "")
            ),
            accessibility: .init(
                singleItemBadgeValue: "",
                multipleItemsBadgeValue: "",
                titleAndBadgeValue: Localization.Templates.titleAndBadgeValue,
                isFontScalingEnabled: true
            )
        )
        let minimizeButton = CallButtonStyle(
            active: CallButtonStyle.StateStyle(
                backgroundColor: activeBackgroundColor,
                image: Asset.callMiminize.image,
                imageColor: activeImageColor,
                title: Localization.Engagement.minimizeVideoButton,
                titleFont: activeTitleFont,
                titleColor: activeTitleColor,
                textStyle: .caption1,
                accessibility: .init(
                    label: Localization.General.selected
                )
            ),
            inactive: CallButtonStyle.StateStyle(
                backgroundColor: inactiveBackgroundColor,
                image: Asset.callMiminize.image,
                imageColor: inactiveImageColor,
                title: Localization.Engagement.minimizeVideoButton,
                titleFont: inactiveTitleFont,
                titleColor: inactiveTitleColor,
                textStyle: .caption1,
                accessibility: .init(label: "")
            ),
            selected: CallButtonStyle.StateStyle(
                backgroundColor: inactiveBackgroundColor,
                image: Asset.callMiminize.image,
                imageColor: inactiveImageColor,
                title: Localization.Engagement.minimizeVideoButton,
                titleFont: inactiveTitleFont,
                titleColor: inactiveTitleColor,
                textStyle: .caption1,
                accessibility: .init(label: "")
            ),
            accessibility: .init(
                singleItemBadgeValue: "",
                multipleItemsBadgeValue: "",
                titleAndBadgeValue: Localization.Templates.titleAndBadgeValue,
                isFontScalingEnabled: true
            )
        )
        let badge = BadgeStyle(
            font: font.caption,
            fontColor: color.baseLight,
            backgroundColor: .fill(color: color.primary)
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
