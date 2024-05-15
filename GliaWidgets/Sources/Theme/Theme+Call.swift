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
                label: Localization.Call.OperatorAvatar.Accessibility.label,
                hint: Localization.Call.OperatorAvatar.Accessibility.hint
            )
        )
        let queue = ConnectStatusStyle(
            firstText: "",
            firstTextFont: font.header1,
            firstTextFontColor: color.baseLight,
            firstTextStyle: .title1,
            secondText: Localization.Engagement.ConnectionScreen.message,
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
            firstText: Localization.Engagement.ConnectionScreen.connectWith,
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
            firstText: Localization.Engagement.Queue.transferring,
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
            onHoldText: Localization.Call.OnHold.icon,
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
            audioTitle: Localization.Engagement.Audio.title,
            videoTitle: Localization.Engagement.Video.title,
            operatorName: Localization.Templates.operatorName,
            operatorNameFont: font.header1,
            operatorNameColor: color.baseLight,
            durationFont: font.bodyText,
            durationColor: color.baseLight,
            topText: Localization.Ios.Engagement.ConnectionScreen.videoNotice,
            topTextFont: font.subtitle,
            topTextColor: color.baseLight,
            bottomText: Localization.Engagement.QueueWait.message,
            bottomTextFont: font.bodyText,
            bottomTextColor: color.baseLight,
            buttonBar: buttonBarStyle,
            onHoldStyle: onHoldStyle,
            flipCameraButtonStyle: .init(
                backgroundColor: .fill(color: .black.withAlphaComponent(0.6)),
                imageColor: .fill(color: .white),
                accessibility: .init(
                    switchToBackCameraAccessibilityLabel: Localization.Call.VisitorVideo.BackCamera.Button.Accessibility.label,
                    switchToBackCameraAccessibilityHint: Localization.Call.VisitorVideo.BackCamera.Button.Accessibility.hint,
                    switchToFrontCameraAccessibilityLabel: Localization.Call.VisitorVideo.FrontCamera.Button.Accessibility.label,
                    switchToFrontCameraAccessibilityHint: Localization.Call.VisitorVideo.FrontCamera.Button.Accessibility.hint
                )
            ),
            accessibility: .init(
                operatorNameHint: Localization.Call.Connect.FirstText.Accessibility.hint,
                durationHint: Localization.Call.Connect.SecondText.Accessibility.hint,
                localVideoLabel: Localization.Call.VisitorVideo.Accessibility.label,
                remoteVideoLabel: Localization.Call.OperatorVideo.Accessibility.label,
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
                title: Localization.Engagement.Chat.title,
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
                title: Localization.Engagement.Chat.title,
                titleFont: inactiveTitleFont,
                titleColor: inactiveTitleColor,
                textStyle: .caption1,
                accessibility: .init(label: "")
            ),
            selected: CallButtonStyle.StateStyle(
                backgroundColor: inactiveBackgroundColor,
                image: Asset.callChat.image,
                imageColor: inactiveImageColor,
                title: Localization.Engagement.Chat.title,
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
                title: Localization.Engagement.Video.title,
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
                title: Localization.Engagement.Video.title,
                titleFont: inactiveTitleFont,
                titleColor: inactiveTitleColor,
                textStyle: .caption1,
                accessibility: .init(label: "")
            ),
            selected: CallButtonStyle.StateStyle(
                backgroundColor: inactiveBackgroundColor,
                image: Asset.callVideoInactive.image,
                imageColor: inactiveImageColor,
                title: Localization.Engagement.Video.title,
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
#warning("check Localization.Call.Unmute.button")
        let muteButton = CallButtonStyle(
            active: CallButtonStyle.StateStyle(
                backgroundColor: activeBackgroundColor,
                image: Asset.callMuteActive.image,
                imageColor: activeImageColor,
                title: Localization.Call.Unmute.button,
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
                title: Localization.Call.Mute.button,
                titleFont: inactiveTitleFont,
                titleColor: inactiveTitleColor,
                textStyle: .caption1,
                accessibility: .init(label: "")
            ),
            selected: CallButtonStyle.StateStyle(
                backgroundColor: inactiveBackgroundColor,
                image: Asset.callMuteInactive.image,
                imageColor: inactiveImageColor,
                title: Localization.Call.Mute.button,
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
                title: Localization.Call.Speaker.button,
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
                title: Localization.Call.Speaker.button,
                titleFont: inactiveTitleFont,
                titleColor: inactiveTitleColor,
                textStyle: .caption1,
                accessibility: .init(label: "")
            ),
            selected: CallButtonStyle.StateStyle(
                backgroundColor: inactiveBackgroundColor,
                image: Asset.callSpeakerInactive.image,
                imageColor: inactiveImageColor,
                title: Localization.Call.Speaker.button,
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
                title: Localization.Engagement.MinimizeVideo.button,
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
                title: Localization.Engagement.MinimizeVideo.button,
                titleFont: inactiveTitleFont,
                titleColor: inactiveTitleColor,
                textStyle: .caption1,
                accessibility: .init(label: "")
            ),
            selected: CallButtonStyle.StateStyle(
                backgroundColor: inactiveBackgroundColor,
                image: Asset.callMiminize.image,
                imageColor: inactiveImageColor,
                title: Localization.Engagement.MinimizeVideo.button,
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
