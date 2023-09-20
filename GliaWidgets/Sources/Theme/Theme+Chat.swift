extension Theme {
    var chatStyle: ChatStyle {
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
                hint: ""
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
                label: Localization.ScreenSharing.VisitorScreen.End.title,
                hint: ""
            )
        )
        let header = HeaderStyle(
            titleFont: font.header2,
            titleColor: color.baseLight,
            backgroundColor: .fill(color: color.primary),
            backButton: backButton,
            closeButton: closeButton,
            endButton: endButton,
            endScreenShareButton: endScreenShareButton,
            accessibility: .init(isFontScalingEnabled: true)
        )

        var secureTranscriptHeader = header
        secureTranscriptHeader.backButton = nil

        let operatorImage = UserImageStyle(
            placeholderImage: Asset.operatorPlaceholder.image,
            placeholderColor: color.baseLight,
            placeholderBackgroundColor: .fill(color: color.primary),
            imageBackgroundColor: .fill(color: .clear),
            transferringImage: Asset.operatorTransferring.image
        )
        let queueOperator = ConnectOperatorStyle(
            operatorImage: operatorImage,
            animationColor: color.primary,
            onHoldOverlay: onHoldOverlay,
            accessibility: .init(
                label: Localization.Chat.OperatorAvatar.Accessibility.label,
                hint: Localization.Call.OperatorAvatar.Accessibility.hint
            )
        )
        let queue = ConnectStatusStyle(
            firstText: "",
            firstTextFont: font.header1,
            firstTextFontColor: color.baseDark,
            firstTextStyle: .title1,
            secondText: Localization.Engagement.ConnectionScreen.message,
            secondTextFont: font.subtitle,
            secondTextFontColor: color.baseNormal,
            secondTextStyle: .footnote,
            accessibility: .init(
                firstTextHint: Localization.Chat.OperatorName.Accessibility.label,
                secondTextHint: nil,
                isFontScalingEnabled: true
            )
        )
        let connecting = ConnectStatusStyle(
            firstText: Localization.Engagement.ConnectionScreen.connectWith,
            firstTextFont: font.header2,
            firstTextFontColor: color.baseDark,
            firstTextStyle: .title2,
            secondText: "",
            secondTextFont: font.header2,
            secondTextFontColor: color.baseDark,
            secondTextStyle: .title2,
            accessibility: .init(
                firstTextHint: Localization.Chat.OperatorName.Accessibility.label,
                secondTextHint: nil,
                isFontScalingEnabled: true
            )
        )
        let connected = ConnectStatusStyle(
            firstText: Localization.Templates.operatorName,
            firstTextFont: font.header1,
            firstTextFontColor: color.baseDark,
            firstTextStyle: .title1,
            secondText: Localization.Chat.OperatorJoined.systemMessage,
            secondTextFont: font.subtitle,
            secondTextFontColor: color.primary,
            secondTextStyle: .footnote,
            accessibility: .init(
                firstTextHint: Localization.Chat.OperatorName.Accessibility.label,
                secondTextHint: nil,
                isFontScalingEnabled: true
            )
        )
        let onHold = ConnectStatusStyle(
            firstText: Localization.Templates.operatorName,
            firstTextFont: font.header1,
            firstTextFontColor: color.baseLight,
            firstTextStyle: .title1,
            secondText: Localization.Chat.OperatorJoined.systemMessage,
            secondTextFont: font.subtitle,
            secondTextFontColor: color.baseLight,
            secondTextStyle: .footnote,
            accessibility: .init(
                firstTextHint: Localization.Chat.OperatorName.Accessibility.label,
                secondTextHint: nil,
                isFontScalingEnabled: true
            )
        )
        let transferring = ConnectStatusStyle(
            firstText: Localization.Engagement.Queue.transferring,
            firstTextFont: font.header1,
            firstTextFontColor: color.baseDark,
            firstTextStyle: .title1,
            secondText: nil,
            secondTextFont: font.subtitle,
            secondTextFontColor: color.primary,
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
        let visitorImageFile = ChatImageFileContentStyle(
            backgroundColor: color.primary,
            accessibility: .init(
                contentAccessibilityLabel: Localization.Chat.Attachment.Message.Accessibility.label,
                youAccessibilityPlaceholder: Localization.General.you,
                isFontScalingEnabled: true
            )
        )
        let visitorMessage = VisitorMessageStyle(
            text: .init(
                color: color.baseLight.hex,
                font: font.bodyText,
                textStyle: .body,
                accessibility: .init(isFontScalingEnabled: true)
            ),
            background: .init(
                background: .fill(color: color.primary),
                borderColor: .clear,
                borderWidth: .zero,
                cornerRadius: 8.49
            ),
            imageFile: visitorImageFile,
            fileDownload: fileDownload,
            status: .init(
                color: color.baseNormal.hex,
                font: font.caption,
                textStyle: .caption1,
                accessibility: .init(isFontScalingEnabled: true)
            ),
            delivered: Localization.Chat.Message.delivered,
            accessibility: .init(isFontScalingEnabled: true)
        )
        let operatorImageFile = ChatImageFileContentStyle(
            backgroundColor: color.baseNeutral,
            accessibility: .init(
                contentAccessibilityLabel: Localization.Chat.Attachment.Message.Accessibility.label,
                youAccessibilityPlaceholder: Localization.General.you,
                isFontScalingEnabled: true
            )
        )
        let operatorText = Text(
            color: color.baseDark.hex,
            font: font.bodyText,
            textStyle: .body,
            accessibility: .init(isFontScalingEnabled: true)
        )
        let operatorMessage = OperatorMessageStyle(
            text: operatorText,
            background: .init(
                background: .fill(color: color.baseNeutral),
                borderColor: .clear,
                borderWidth: .zero,
                cornerRadius: 8.49
            ),
            imageFile: operatorImageFile,
            fileDownload: fileDownload,
            operatorImage: operatorImage,
            accessibility: .init(isFontScalingEnabled: true)
        )
        let operatorTypingIndicator = OperatorTypingIndicatorStyle(
            color: color.primary,
            accessibility: .init(label: Localization.Chat.Status.Typing.Accessibility.label)
        )
        let choiceCardImageFile = ChatImageFileContentStyle(
            backgroundColor: color.baseLight,
            accessibility: .init(
                contentAccessibilityLabel: Localization.Chat.Attachment.Message.Accessibility.label,
                youAccessibilityPlaceholder: Localization.General.you,
                isFontScalingEnabled: true
            )
        )
        let choiceCardOptionNormalState = Button(
            background: .fill(color: color.baseNeutral),
            title: .init(
                color: color.baseDark.hex,
                font: font.bodyText,
                textStyle: .body,
                accessibility: .init(isFontScalingEnabled: true)
            ),
            cornerRadius: 4,
            accessibility: .init(
                label: "",
                isFontScalingEnabled: true
            )
        )
        let choiceCardOptionSelectedState = Button(
            background: .fill(color: color.primary),
            title: .init(
                color: color.baseLight.hex,
                font: font.bodyText,
                textStyle: .body,
                accessibility: .init(isFontScalingEnabled: true)
            ),
            cornerRadius: 4,
            accessibility: .init(
                label: Localization.General.selected,
                isFontScalingEnabled: true
            )
        )
        let choiceCardOptionDisabledState = Button(
            background: .fill(color: color.baseNeutral),
            title: .init(
                color: color.baseShade.hex,
                font: font.bodyText,
                textStyle: .body,
                accessibility: .init(isFontScalingEnabled: true)
            ),
            cornerRadius: 4,
            borderWidth: 1,
            borderColor: color.baseShade.toRGBAHex(),
            accessibility: .init(
                label: Localization.Chat.ChoiceCard.Button.Disabled.Accessibility.label,
                isFontScalingEnabled: true
            )
        )
        let choiceCardOption = ChoiceCardStyle.Option(
            normal: choiceCardOptionNormalState,
            selected: choiceCardOptionSelectedState,
            disabled: choiceCardOptionDisabledState
        )
        let choiceCard = ChoiceCardStyle(
            text: .init(
                color: color.baseDark.hex,
                font: font.bodyText,
                textStyle: .body,
                accessibility: .init(isFontScalingEnabled: true)
            ),
            background: .init(
                background: .fill(color: color.baseLight),
                borderColor: color.primary.cgColor,
                borderWidth: 1,
                cornerRadius: 8
            ),
            imageFile: choiceCardImageFile,
            fileDownload: fileDownload,
            operatorImage: operatorImage,
            choiceOption: choiceCardOption,
            accessibility: .init(imageLabel: Localization.Chat.ChoiceCard.Image.Accessibility.label)
        )
        let mediaButton = MessageButtonStyle(
            image: Asset.chatPickMedia.image,
            color: color.baseNormal,
            accessibility: .init(accessibilityLabel: Localization.Chat.attachFiles)
        )
        let sendButton = MessageButtonStyle(
            image: Asset.chatSend.image,
            color: color.primary,
            accessibility: .init(accessibilityLabel: Localization.General.send)
        )
        let messageEntry = ChatMessageEntryStyle(
            messageFont: font.bodyText,
            messageColor: color.baseDark,
            enterMessagePlaceholder: Localization.Chat.Input.placeholder,
            startEngagementPlaceholder: Localization.Chat.Message.startEngagementPlaceholder,
            choiceCardPlaceholder: Localization.Chat.ChoiceCard.placeholderMessage,
            placeholderFont: font.bodyText,
            placeholderColor: color.baseNormal,
            separatorColor: color.baseShade,
            backgroundColor: color.baseLight,
            mediaButton: mediaButton,
            sendButton: sendButton,
            uploadList: uploadListStyle,
            accessibility: .init(
                messageInputAccessibilityLabel: Localization.General.message,
                isFontScalingEnabled: true
            )
        )
        let audioUpgrade = ChatCallUpgradeStyle(
            icon: Asset.upgradeAudio.image,
            iconColor: color.primary,
            text: Localization.Chat.MediaUpgrade.Audio.systemMessage,
            textFont: font.bodyText,
            textColor: color.baseDark,
            durationFont: font.bodyText,
            durationColor: color.baseNormal,
            borderColor: color.baseShade,
            accessibility: .init(
                durationTextHint: Localization.Call.Duration.Accessibility.label,
                isFontScalingEnabled: true
            )
        )
        let videoUpgrade = ChatCallUpgradeStyle(
            icon: Asset.upgradeVideo.image,
            iconColor: color.primary,
            text: Localization.Chat.MediaUpgrade.Video.systemMessage,
            textFont: font.bodyText,
            textColor: color.baseDark,
            durationFont: font.bodyText,
            durationColor: color.baseNormal,
            borderColor: color.baseShade,
            accessibility: .init(
                durationTextHint: Localization.Call.Duration.Accessibility.label,
                isFontScalingEnabled: true
            )
        )
        let userImage = UserImageStyle(
            placeholderImage: Asset.operatorPlaceholder.image,
            placeholderColor: color.baseLight,
            placeholderBackgroundColor: .fill(color: color.primary),
            imageBackgroundColor: .fill(color: .clear),
            transferringImage: Asset.operatorTransferring.image
        )
        let callBubble = BubbleStyle(
            userImage: userImage,
            accessibility: .init(
                label: Localization.Call.OperatorAvatar.Accessibility.label,
                hint: Localization.Call.Bubble.Accessibility.hint
            )
        )
        let unreadMessageIndicator = UnreadMessageIndicatorStyle(
            badgeFont: font.caption,
            badgeTextColor: color.baseLight,
            badgeColor: .fill(color: color.primary),
            placeholderImage: Asset.operatorPlaceholder.image,
            placeholderColor: color.baseLight,
            placeholderBackgroundColor: .fill(color: color.primary),
            imageBackgroundColor: .fill(color: .clear),
            transferringImage: Asset.operatorTransferring.image,
            accessibility: .init(label: Localization.Chat.Message.Unread.Accessibility.label)
        )

        let unreadMessageDivider = UnreadMessageDividerStyle(
            title: Localization.Chat.unreadMessageDivider,
            titleColor: Color.baseNormal,
            titleFont: font.buttonLabel,
            lineColor: color.primary,
            accessibility: .init(isFontScalingEnabled: true)
        )

        let systemMessage = SystemMessageStyle(
            text: operatorText,
            background: Theme.Layer(
                background: .fill(color: color.baseNeutral),
                borderColor: .clear,
                borderWidth: .zero,
                cornerRadius: 8.49
            ),
            imageFile: operatorImageFile,
            fileDownload: fileDownload
        )

        return ChatStyle(
            header: header,
            connect: connect,
            backgroundColor: .fill(color: color.baseLight),
            preferredStatusBarStyle: .lightContent,
            title: Localization.Engagement.Chat.title,
            visitorMessageStyle: visitorMessage,
            operatorMessageStyle: operatorMessage,
            choiceCardStyle: choiceCard,
            messageEntry: messageEntry,
            audioUpgrade: audioUpgrade,
            videoUpgrade: videoUpgrade,
            callBubble: callBubble,
            pickMedia: pickMedia,
            unreadMessageIndicator: unreadMessageIndicator,
            operatorTypingIndicator: operatorTypingIndicator,
            accessibility: .init(
                operator: Localization.Engagement.defaultOperator,
                visitor: Localization.General.you,
                isFontScalingEnabled: true
            ),
            secureTranscriptTitle: Localization.Engagement.SecureMessaging.title,
            secureTranscriptHeader: secureTranscriptHeader,
            unreadMessageDivider: unreadMessageDivider,
            systemMessageStyle: systemMessage,
            gliaVirtualAssistant: gliaVirtualAssistantStyle
        )
    }

    private var uploadListStyle: FileUploadListStyle {
        let filePreview = FilePreviewStyle(
            fileFont: font.subtitle,
            fileColor: color.baseLight,
            errorIcon: Asset.uploadError.image,
            errorIconColor: color.systemNegative,
            backgroundColor: color.primary,
            errorBackgroundColor: color.baseNeutral,
            accessibility: .init(isFontScalingEnabled: true)
        )
        let uploading = FileUploadStateStyle(
            text: Localization.Chat.File.Upload.inProgress,
            font: font.mediumSubtitle2,
            textColor: color.baseDark,
            infoFont: font.caption,
            infoColor: color.baseNormal
        )
        let uploaded = FileUploadStateStyle(
            text: Localization.Chat.File.Upload.success,
            font: font.mediumSubtitle2,
            textColor: color.baseDark,
            infoFont: font.caption,
            infoColor: color.baseNormal
        )
        let error = FileUploadErrorStateStyle(
            text: Localization.Chat.File.Upload.failed,
            font: font.mediumSubtitle2,
            textColor: color.baseDark,
            infoFont: font.caption,
            infoColor: color.systemNegative,
            infoFileTooBig: Localization.Chat.File.SizeLimit.error,
            infoUnsupportedFileType: Localization.Chat.Attachment.unsupportedFile,
            infoSafetyCheckFailed: Localization.Chat.File.InfectedFile.error,
            infoNetworkError: Localization.Chat.File.Upload.networkError,
            infoGenericError: Localization.Chat.File.Upload.genericError
        )
        let upload = FileUploadStyle(
            filePreview: filePreview,
            uploading: uploading,
            uploaded: uploaded,
            error: error,
            progressColor: color.primary,
            errorProgressColor: color.systemNegative,
            progressBackgroundColor: color.baseNeutral,
            removeButtonImage: Asset.uploadRemove.image,
            removeButtonColor: color.baseNormal,
            accessibility: .init(
                removeButtonAccessibilityLabel: Localization.Chat.File.RemoveUpload.Accessibility.label,
                progressPercentValue: Localization.Templates.percentValue,
                fileNameWithProgressValue: Localization.Templates.fileNameWithProgressValue,
                isFontScalingEnabled: true
            )
        )

        return FileUploadListStyle(item: upload)
    }

    private var fileDownload: ChatFileDownloadStyle {
        let filePreview = FilePreviewStyle(
            fileFont: font.subtitle,
            fileColor: color.baseLight,
            errorIcon: Asset.uploadError.image,
            errorIconColor: color.systemNegative,
            backgroundColor: color.primary,
            errorBackgroundColor: color.baseNeutral,
            accessibility: .init(isFontScalingEnabled: true)
        )
        let download = ChatFileDownloadStateStyle(
            text: Localization.General.download,
            font: font.mediumSubtitle2,
            textColor: color.baseDark,
            infoFont: font.caption,
            infoColor: color.baseNormal
        )
        let downloading = ChatFileDownloadStateStyle(
            text: Localization.Chat.Download.downloading,
            font: font.mediumSubtitle2,
            textColor: color.baseDark,
            infoFont: font.caption,
            infoColor: color.baseNormal
        )
        let open = ChatFileDownloadStateStyle(
            text: Localization.General.open,
            font: font.mediumSubtitle2,
            textColor: color.baseDark,
            infoFont: font.caption,
            infoColor: color.baseNormal
        )
        let error = ChatFileDownloadErrorStateStyle(
            text: Localization.Chat.Download.failed,
            font: font.mediumSubtitle2,
            textColor: color.systemNegative,
            infoFont: font.caption,
            infoColor: color.baseNormal,
            separatorText: " | ",
            separatorFont: font.subtitle,
            separatorTextColor: color.baseDark,
            retryText: Localization.General.retry,
            retryFont: font.mediumSubtitle2,
            retryTextColor: color.baseDark
        )

        return ChatFileDownloadStyle(
            filePreview: filePreview,
            download: download,
            downloading: downloading,
            open: open,
            error: error,
            progressColor: color.primary,
            errorProgressColor: color.systemNegative,
            progressBackgroundColor: color.baseNeutral,
            backgroundColor: .white,
            borderColor: color.baseNeutral,
            accessibility: .init(
                contentAccessibilityLabel: Localization.Chat.Attachment.Message.Accessibility.label,
                youAccessibilityPlaceholder: Localization.General.you,
                isFontScalingEnabled: true
            ),
            downloadAccessibility: .init(
                noneState: Localization.Templates.downloadWithFileState,
                downloadingState: Localization.Templates.downloadWithFileStateAndPercentValue,
                downloadedState: Localization.Templates.downloadWithFileState,
                errorState: Localization.Templates.downloadWithFileState
            )
        )
    }

    private var pickMedia: AttachmentSourceListStyle {
        let itemFont = font.bodyText
        let itemFontColor = color.baseDark
        let itemIconColor = color.baseDark

        let pickPhoto = AttachmentSourceItemStyle(
            kind: .photoLibrary,
            title: Localization.Chat.Attachment.photoLibrary,
            titleFont: itemFont,
            titleColor: itemFontColor,
            icon: Asset.photoLibraryIcon.image,
            iconColor: itemIconColor,
            accessibility: .init(isFontScalingEnabled: true)
        )
        let takePhoto = AttachmentSourceItemStyle(
            kind: .takePhoto,
            title: Localization.Chat.Attachment.takePhoto,
            titleFont: itemFont,
            titleColor: itemFontColor,
            icon: Asset.cameraIcon.image,
            iconColor: itemIconColor,
            accessibility: .init(isFontScalingEnabled: true)
        )
        let browse = AttachmentSourceItemStyle(
            kind: .browse,
            title: Localization.General.browse,
            titleFont: itemFont,
            titleColor: itemFontColor,
            icon: Asset.browseIcon.image,
            iconColor: itemIconColor,
            accessibility: .init(isFontScalingEnabled: true)
        )

        return AttachmentSourceListStyle(
            items: [pickPhoto, takePhoto, browse],
            separatorColor: color.baseShade,
            backgroundColor: color.baseNeutral
        )
    }
}
