extension Theme {
    var chatStyle: ChatStyle {
        typealias Chat = L10n.Chat
        typealias Accessibility = Chat.Accessibility

        let onHoldOverlay = OnHoldOverlayStyle(
            image: Asset.callOnHold.image,
            imageColor: .fill(color: .white),
            imageSize: .init(width: 40, height: 40)
        )
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
            title: Chat.EndButton.title,
            titleFont: font.buttonLabel,
            titleColor: color.baseLight,
            backgroundColor: .fill(color: color.systemNegative),
            accessibility: .init(
                label: Accessibility.Header.EndButton.label,
                isFontScalingEnabled: true
            )
        )
        let endScreenShareButton = HeaderButtonStyle(
            image: Asset.startScreenShare.image,
            color: color.baseLight,
            accessibility: .init(
                label: Accessibility.Header.EndScreenShareButton.label,
                hint: Accessibility.Header.EndScreenShareButton.hint
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
                label: Accessibility.Operator.Avatar.label,
                hint: Accessibility.Operator.Avatar.hint
            )
        )
        let queue = ConnectStatusStyle(
            firstText: Chat.Connect.Queue.firstText,
            firstTextFont: font.header1,
            firstTextFontColor: color.baseDark,
            firstTextStyle: .title1,
            secondText: Chat.Connect.Queue.secondText,
            secondTextFont: font.subtitle,
            secondTextFontColor: color.baseNormal,
            secondTextStyle: .footnote,
            accessibility: .init(
                firstTextHint: Accessibility.Connect.Queue.FirstText.hint,
                secondTextHint: nil,
                isFontScalingEnabled: true
            )
        )
        let connecting = ConnectStatusStyle(
            firstText: Chat.Connect.Connecting.firstText,
            firstTextFont: font.header2,
            firstTextFontColor: color.baseDark,
            firstTextStyle: .title2,
            secondText: Chat.Connect.Connecting.secondText,
            secondTextFont: font.header2,
            secondTextFontColor: color.baseDark,
            secondTextStyle: .title2,
            accessibility: .init(
                firstTextHint: Accessibility.Connect.Connecting.FirstText.hint,
                secondTextHint: nil,
                isFontScalingEnabled: true
            )
        )
        let connected = ConnectStatusStyle(
            firstText: Chat.Connect.Connected.firstText,
            firstTextFont: font.header1,
            firstTextFontColor: color.baseDark,
            firstTextStyle: .title1,
            secondText: Chat.Connect.Connected.secondText,
            secondTextFont: font.subtitle,
            secondTextFontColor: color.primary,
            secondTextStyle: .footnote,
            accessibility: .init(
                firstTextHint: Accessibility.Connect.Connected.FirstText.hint,
                secondTextHint: nil,
                isFontScalingEnabled: true
            )
        )
        let onHold = ConnectStatusStyle(
            firstText: Chat.Connect.Connected.firstText,
            firstTextFont: font.header1,
            firstTextFontColor: color.baseLight,
            firstTextStyle: .title1,
            secondText: Chat.Connect.Connected.secondText,
            secondTextFont: font.subtitle,
            secondTextFontColor: color.baseLight,
            secondTextStyle: .footnote,
            accessibility: .init(
                firstTextHint: Accessibility.Connect.Connected.FirstText.hint,
                secondTextHint: nil,
                isFontScalingEnabled: true
            )
        )
        let transferring = ConnectStatusStyle(
            firstText: Chat.Connect.Transferring.firstText,
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
        let visitorText = ChatTextContentStyle(
            textFont: font.bodyText,
            textColor: color.baseLight,
            backgroundColor: color.primary,
            accessibility: .init(isFontScalingEnabled: true)
        )
        let visitorImageFile = ChatImageFileContentStyle(
            backgroundColor: color.primary,
            accessibility: .init(
                contentAccessibilityLabel: Accessibility.Message.attachmentMessageLabel,
                youAccessibilityPlaceholder: Accessibility.Message.you,
                isFontScalingEnabled: true
            )
        )
        let visitorMessage = VisitorChatMessageStyle(
            text: visitorText,
            imageFile: visitorImageFile,
            fileDownload: fileDownload,
            statusFont: font.caption,
            statusColor: color.baseNormal,
            statusTextStyle: .caption1,
            delivered: Chat.Message.Status.delivered,
            accessibility: .init(isFontScalingEnabled: true)
        )
        let operatorText = ChatTextContentStyle(
            textFont: font.bodyText,
            textColor: color.baseDark,
            backgroundColor: Color.lightGrey,
            accessibility: .init(isFontScalingEnabled: true)
        )
        let operatorImageFile = ChatImageFileContentStyle(
            backgroundColor: Color.lightGrey,
            accessibility: .init(
                contentAccessibilityLabel: Accessibility.Message.attachmentMessageLabel,
                youAccessibilityPlaceholder: Accessibility.Message.you,
                isFontScalingEnabled: true
            )
        )
        let operatorMessage = OperatorChatMessageStyle(
            text: operatorText,
            imageFile: operatorImageFile,
            fileDownload: fileDownload,
            operatorImage: operatorImage
        )
        let operatorTypingIndicator = OperatorTypingIndicatorStyle(
            color: color.primary,
            accessibility: .init(label: Accessibility.Message.Operator.TypingIndicator.label)
        )
        let choiceCardText = ChatTextContentStyle(
            textFont: font.bodyText,
            textColor: color.baseDark,
            backgroundColor: color.baseLight,
            accessibility: .init(isFontScalingEnabled: true)
        )
        let choiceCardImageFile = ChatImageFileContentStyle(
            backgroundColor: color.baseLight,
            accessibility: .init(
                contentAccessibilityLabel: Accessibility.Message.attachmentMessageLabel,
                youAccessibilityPlaceholder: Accessibility.Message.you,
                isFontScalingEnabled: true
            )
        )
        let choiceCardOptionNormalState = ChoiceCardOptionStateStyle(
            textFont: font.bodyText,
            textColor: color.baseDark,
            backgroundColor: Color.lightGrey,
            borderColor: nil,
            accessibility: .init(
                value: Accessibility.Message.ChoiceCard.ButtonState.normal,
                isFontScalingEnabled: true
            )
        )
        let choiceCardOptionSelectedState = ChoiceCardOptionStateStyle(
            textFont: font.bodyText,
            textColor: color.baseLight,
            backgroundColor: color.primary,
            borderColor: nil,
            accessibility: .init(
                value: Accessibility.Message.ChoiceCard.ButtonState.selected,
                isFontScalingEnabled: true
            )
        )
        let choiceCardOptionDisabledState = ChoiceCardOptionStateStyle(
            textFont: font.bodyText,
            textColor: Color.grey,
            backgroundColor: Color.lightGrey,
            borderColor: Color.baseShade,
            accessibility: .init(
                value: Accessibility.Message.ChoiceCard.ButtonState.disabled,
                isFontScalingEnabled: true
            )
        )
        let choiceCardOption = ChoiceCardOptionStyle(
            normal: choiceCardOptionNormalState,
            selected: choiceCardOptionSelectedState,
            disabled: choiceCardOptionDisabledState
        )
        let choiceCard = ChoiceCardStyle(
            mainText: choiceCardText,
            frameColor: color.primary,
            backgroundColor: color.baseLight,
            imageFile: choiceCardImageFile,
            fileDownload: fileDownload,
            operatorImage: operatorImage,
            choiceOption: choiceCardOption,
            accessibility: .init(imageLabel: Accessibility.Message.ChoiceCard.Image.label)
        )
        let mediaButton = MessageButtonStyle(
            image: Asset.chatPickMedia.image,
            color: color.baseNormal,
            accessibility: .init(accessibilityLabel: Accessibility.PickMedia.PickAttachmentButton.label)
        )
        let sendButton = MessageButtonStyle(
            image: Asset.chatSend.image,
            color: color.primary,
            accessibility: .init(accessibilityLabel: Accessibility.Message.SendButton.label)
        )
        let messageEntry = ChatMessageEntryStyle(
            messageFont: font.bodyText,
            messageColor: color.baseDark,
            enterMessagePlaceholder: Chat.Message.enterMessagePlaceholder,
            startEngagementPlaceholder: Chat.Message.startEngagementPlaceholder,
            choiceCardPlaceholder: Chat.Message.choiceCardPlaceholder,
            placeholderFont: font.bodyText,
            placeholderColor: color.baseNormal,
            separatorColor: color.baseShade,
            backgroundColor: color.background,
            mediaButton: mediaButton,
            sendButton: sendButton,
            uploadList: uploadListStyle,
            accessibility: .init(
                messageInputAccessibilityLabel: Accessibility.Message.MessageInput.label,
                isFontScalingEnabled: true
            )
        )
        let audioUpgrade = ChatCallUpgradeStyle(
            icon: Asset.upgradeAudio.image,
            iconColor: color.primary,
            text: Chat.Upgrade.Audio.text,
            textFont: font.bodyText,
            textColor: color.baseDark,
            durationFont: font.bodyText,
            durationColor: color.baseNormal,
            borderColor: color.baseShade,
            accessibility: .init(
                durationTextHint: Accessibility.ChatCallUpgrade.Audio.Duration.hint,
                isFontScalingEnabled: true
            )
        )
        let videoUpgrade = ChatCallUpgradeStyle(
            icon: Asset.upgradeVideo.image,
            iconColor: color.primary,
            text: Chat.Upgrade.Video.text,
            textFont: font.bodyText,
            textColor: color.baseDark,
            durationFont: font.bodyText,
            durationColor: color.baseNormal,
            borderColor: color.baseShade,
            accessibility: .init(
                durationTextHint: Accessibility.ChatCallUpgrade.Video.Duration.hint,
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
                label: L10n.Call.Accessibility.Bubble.label,
                hint: L10n.Call.Accessibility.Bubble.hint
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
            accessibility: .init(label: Accessibility.Message.UnreadMessagesIndicator.label)
        )
        return ChatStyle(
            header: header,
            connect: connect,
            backgroundColor: .fill(color: color.background),
            preferredStatusBarStyle: .lightContent,
            title: Chat.title,
            visitorMessage: visitorMessage,
            operatorMessage: operatorMessage,
            choiceCard: choiceCard,
            messageEntry: messageEntry,
            audioUpgrade: audioUpgrade,
            videoUpgrade: videoUpgrade,
            callBubble: callBubble,
            pickMedia: pickMedia,
            unreadMessageIndicator: unreadMessageIndicator,
            operatorTypingIndicator: operatorTypingIndicator,
            accessibility: .init(
                operator: L10n.operator,
                visitor: Accessibility.visitorName,
                isFontScalingEnabled: true
            )
        )
    }

    private var uploadListStyle: FileUploadListStyle {
        typealias Upload = L10n.Chat.Upload
        typealias Accessibility = L10n.Chat.Accessibility.Upload

        let filePreview = FilePreviewStyle(
            fileFont: font.subtitle,
            fileColor: color.baseLight,
            errorIcon: Asset.uploadError.image,
            errorIconColor: color.systemNegative,
            backgroundColor: color.primary,
            errorBackgroundColor: Color.lightGrey,
            accessibility: .init(isFontScalingEnabled: true)
        )
        let uploading = FileUploadStateStyle(
            text: Upload.uploading,
            font: font.mediumSubtitle2,
            textColor: color.baseDark,
            infoFont: font.caption,
            infoColor: color.baseNormal
        )
        let uploaded = FileUploadStateStyle(
            text: Upload.uploaded,
            font: font.mediumSubtitle2,
            textColor: color.baseDark,
            infoFont: font.caption,
            infoColor: color.baseNormal
        )
        let error = FileUploadErrorStateStyle(
            text: Upload.failed,
            font: font.mediumSubtitle2,
            textColor: color.baseDark,
            infoFont: font.caption,
            infoColor: color.systemNegative,
            infoFileTooBig: Upload.Error.fileTooBig,
            infoUnsupportedFileType: Upload.Error.unsupportedFileType,
            infoSafetyCheckFailed: Upload.Error.safetyCheckFailed,
            infoNetworkError: Upload.Error.network,
            infoGenericError: Upload.Error.generic
        )
        let upload = FileUploadStyle(
            filePreview: filePreview,
            uploading: uploading,
            uploaded: uploaded,
            error: error,
            progressColor: color.primary,
            errorProgressColor: color.systemNegative,
            progressBackgroundColor: Color.lightGrey,
            removeButtonImage: Asset.uploadRemove.image,
            removeButtonColor: color.baseNormal,
            accessibility: .init(
                removeButtonAccessibilityLabel: Accessibility.RemoveUpload.label,
                progressPercentValue: Accessibility.Progress.percentValue,
                fileNameWithProgressValue: Accessibility.Progress.fileNameWithProgressValue,
                isFontScalingEnabled: true
            )
        )

        return FileUploadListStyle(item: upload)
    }

    private var fileDownload: ChatFileDownloadStyle {
        typealias Download = L10n.Chat.Download
        typealias Accessibility = L10n.Chat.Accessibility

        let filePreview = FilePreviewStyle(
            fileFont: font.subtitle,
            fileColor: color.baseLight,
            errorIcon: Asset.uploadError.image,
            errorIconColor: color.systemNegative,
            backgroundColor: color.primary,
            errorBackgroundColor: Color.lightGrey,
            accessibility: .init(isFontScalingEnabled: true)
        )
        let download = ChatFileDownloadStateStyle(
            text: Download.download,
            font: font.mediumSubtitle2,
            textColor: color.baseDark,
            infoFont: font.caption,
            infoColor: color.baseNormal
        )
        let downloading = ChatFileDownloadStateStyle(
            text: Download.downloading,
            font: font.mediumSubtitle2,
            textColor: color.baseDark,
            infoFont: font.caption,
            infoColor: color.baseNormal
        )
        let open = ChatFileDownloadStateStyle(
            text: Download.open,
            font: font.mediumSubtitle2,
            textColor: color.baseDark,
            infoFont: font.caption,
            infoColor: color.baseNormal
        )
        let error = ChatFileDownloadErrorStateStyle(
            text: Download.failed,
            font: font.mediumSubtitle2,
            textColor: color.systemNegative,
            infoFont: font.caption,
            infoColor: color.baseNormal,
            separatorText: Download.Failed.separator,
            separatorFont: font.subtitle,
            separatorTextColor: color.baseDark,
            retryText: Download.Failed.retry,
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
            progressBackgroundColor: Color.lightGrey,
            backgroundColor: .white,
            borderColor: Color.lightGrey,
            accessibility: .init(
                contentAccessibilityLabel: Accessibility.Message.attachmentMessageLabel,
                youAccessibilityPlaceholder: Accessibility.Message.you,
                isFontScalingEnabled: true
            ),
            downloadAccessibility: .init(
                noneState: Accessibility.Download.State.none,
                downloadingState: Accessibility.Download.State.downloading,
                downloadedState: Accessibility.Download.State.downloaded,
                errorState: Accessibility.Download.State.error
            )
        )
    }

    private var pickMedia: AttachmentSourceListStyle {
        typealias Chat = L10n.Chat.PickMedia

        let itemFont = font.bodyText
        let itemFontColor = color.baseDark
        let itemIconColor = color.baseDark

        let pickPhoto = AttachmentSourceItemStyle(
            kind: .photoLibrary,
            title: Chat.photo,
            titleFont: itemFont,
            titleColor: itemFontColor,
            icon: Asset.photoLibraryIcon.image,
            iconColor: itemIconColor,
            accessibility: .init(isFontScalingEnabled: true)
        )
        let takePhoto = AttachmentSourceItemStyle(
            kind: .takePhoto,
            title: Chat.takePhoto,
            titleFont: itemFont,
            titleColor: itemFontColor,
            icon: Asset.cameraIcon.image,
            iconColor: itemIconColor,
            accessibility: .init(isFontScalingEnabled: true)
        )
        let browse = AttachmentSourceItemStyle(
            kind: .browse,
            title: Chat.browse,
            titleFont: itemFont,
            titleColor: itemFontColor,
            icon: Asset.browseIcon.image,
            iconColor: itemIconColor,
            accessibility: .init(isFontScalingEnabled: true)
        )

        return AttachmentSourceListStyle(
            items: [pickPhoto, takePhoto, browse],
            separatorColor: color.baseShade,
            backgroundColor: Color.lightGrey
        )
    }
}
