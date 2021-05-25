extension Theme {
    var chatStyle: ChatStyle {
        typealias Chat = L10n.Chat

        let header = HeaderStyle(
            titleFont: font.header2,
            titleColor: color.baseLight,
            backgroundColor: color.primary
        )
        let backButton = HeaderButtonStyle(
            image: Asset.back.image,
            color: color.baseLight
        )
        let closeButton = HeaderButtonStyle(
            image: Asset.close.image,
            color: color.baseLight
        )
        let operatorImage = UserImageStyle(
            placeholderImage: Asset.operatorPlaceholder.image,
            placeholderColor: color.baseLight,
            placeholderBackgroundColor: color.primary,
            imageBackgroundColor: .clear
        )
        let queueOperator = ConnectOperatorStyle(
            operatorImage: operatorImage,
            animationColor: color.primary
        )
        let queue = ConnectStatusStyle(
            firstText: Chat.Connect.Queue.firstText,
            firstTextFont: font.header1,
            firstTextFontColor: color.baseDark,
            secondText: Chat.Connect.Queue.secondText,
            secondTextFont: font.subtitle,
            secondTextFontColor: color.baseNormal
        )
        let connecting = ConnectStatusStyle(
            firstText: Chat.Connect.Connecting.firstText,
            firstTextFont: font.header2,
            firstTextFontColor: color.baseDark,
            secondText: Chat.Connect.Connecting.secondText,
            secondTextFont: font.header2,
            secondTextFontColor: color.baseDark
        )
        let connected = ConnectStatusStyle(
            firstText: Chat.Connect.Connected.firstText,
            firstTextFont: font.header1,
            firstTextFontColor: color.baseDark,
            secondText: Chat.Connect.Connected.secondText,
            secondTextFont: font.subtitle,
            secondTextFontColor: color.primary
        )
        let connect = ConnectStyle(
            queueOperator: queueOperator,
            queue: queue,
            connecting: connecting,
            connected: connected
        )
        let visitorText = ChatTextContentStyle(
            textFont: font.bodyText,
            textColor: color.baseLight,
            backgroundColor: color.primary
        )
        let visitorImageFile = ChatImageFileContentStyle(
            backgroundColor: color.primary
        )
        let visitorMessage = VisitorChatMessageStyle(
            text: visitorText,
            imageFile: visitorImageFile,
            fileDownload: fileDownload,
            statusFont: font.caption,
            statusColor: color.baseNormal,
            delivered: Chat.Message.Status.delivered
        )
        let operatorText = ChatTextContentStyle(
            textFont: font.bodyText,
            textColor: color.baseDark,
            backgroundColor: Color.lightGrey
        )
        let operatorImageFile = ChatImageFileContentStyle(
            backgroundColor: Color.lightGrey
        )
        let operatorMessage = OperatorChatMessageStyle(
            text: operatorText,
            imageFile: operatorImageFile,
            fileDownload: fileDownload,
            operatorImage: operatorImage
        )
        let choiceCardText = ChatTextContentStyle(
            textFont: font.bodyText,
            textColor: color.baseDark,
            backgroundColor: color.baseLight
        )
        let choiceCardImageFile = ChatImageFileContentStyle(
            backgroundColor: color.baseLight
        )
        let choiceCardOption = ChoiceCardOptionStyle(
            textFont: font.bodyText,
            normalTextColor: color.baseDark,
            normalBackgroundColor: Color.lightGrey,
            highlightedTextColor: color.baseLight,
            highlightedBackgroundColor: color.primary,
            disabledTextColor: Color.grey,
            disabledBackgroundColor: Color.lightGrey
        )
        let choiceCard = ChoiceCardStyle(
            mainText: choiceCardText,
            frameColor: color.primary,
            imageFile: choiceCardImageFile,
            fileDownload: fileDownload,
            operatorImage: operatorImage,
            choiceOption: choiceCardOption
        )
        let endButton = ActionButtonStyle(
            title: Chat.EndButton.title,
            titleFont: font.buttonLabel,
            titleColor: color.baseLight,
            backgroundColor: color.systemNegative
        )
        let endScreenShareButton = HeaderButtonStyle(
            image: Asset.startScreenShare.image,
            color: color.secondary
        )
        let mediaButton = MessageButtonStyle(
            image: Asset.chatPickMedia.image,
            color: color.baseNormal
        )
        let sendButton = MessageButtonStyle(
            image: Asset.chatSend.image,
            color: color.primary
        )
        let messageEntry = ChatMessageEntryStyle(
            messageFont: font.bodyText,
            messageColor: color.baseDark,
            placeholder: Chat.Message.placeholder,
            choiceCardPlaceholder: Chat.Message.choiceCardPlaceholder,
            placeholderFont: font.bodyText,
            placeholderColor: color.baseNormal,
            separatorColor: color.baseShade,
            backgroundColor: color.background,
            mediaButton: mediaButton,
            sendButton: sendButton,
            uploadList: uploadListStyle
        )
        let audioUpgrade = ChatCallUpgradeStyle(
            icon: Asset.upgradeAudio.image,
            iconColor: color.primary,
            text: Chat.Upgrade.Audio.text,
            textFont: font.bodyText,
            textColor: color.baseDark,
            durationFont: font.bodyText,
            durationColor: color.baseNormal,
            borderColor: color.baseShade
        )
        let videoUpgrade = ChatCallUpgradeStyle(
            icon: Asset.upgradeVideo.image,
            iconColor: color.primary,
            text: Chat.Upgrade.Video.text,
            textFont: font.bodyText,
            textColor: color.baseDark,
            durationFont: font.bodyText,
            durationColor: color.baseNormal,
            borderColor: color.baseShade
        )
        let userImage = UserImageStyle(
            placeholderImage: Asset.operatorPlaceholder.image,
            placeholderColor: color.baseLight,
            placeholderBackgroundColor: color.primary,
            imageBackgroundColor: .clear
        )
        let callBubble = BubbleStyle(
            userImage: userImage
        )
        let newMessageIndicator = NewMessageIndicatorStyle(
            badgeFont: font.caption,
            badgeTextColor: color.baseLight,
            badgeColor: color.primary,
            placeholderImage: Asset.operatorPlaceholder.image,
            placeholderColor: color.baseLight,
            placeholderBackgroundColor: color.primary,
            imageBackgroundColor: .clear
        )
        return ChatStyle(
            header: header,
            connect: connect,
            backgroundColor: color.background,
            endButton: endButton,
            endScreenShareButton: endScreenShareButton,
            preferredStatusBarStyle: .lightContent,
            title: Chat.title,
            backButton: backButton,
            closeButton: closeButton,
            visitorMessage: visitorMessage,
            operatorMessage: operatorMessage,
            choiceCard: choiceCard,
            messageEntry: messageEntry,
            audioUpgrade: audioUpgrade,
            videoUpgrade: videoUpgrade,
            callBubble: callBubble,
            pickMedia: pickMedia,
            newMessageIndicator: newMessageIndicator
        )
    }

    private var uploadListStyle: FileUploadListStyle {
        typealias Upload = L10n.Chat.Upload

        let fileImage = FileImageStyle(
            fileFont: font.subtitle,
            fileColor: color.baseLight,
            errorIcon: Asset.uploadError.image,
            errorIconColor: color.systemNegative,
            backgroundColor: color.primary,
            errorBackgroundColor: Color.lightGrey
        )
        let uploading = FileUploadStateStyle(
            text: Upload.uploading,
            font: font.mediumSubtitle,
            textColor: color.baseDark,
            infoFont: font.caption,
            infoColor: color.baseNormal
        )
        let uploaded = FileUploadStateStyle(
            text: Upload.uploaded,
            font: font.mediumSubtitle,
            textColor: color.baseDark,
            infoFont: font.caption,
            infoColor: color.baseNormal
        )
        let error = FileUploadErrorStateStyle(
            text: Upload.failed,
            font: font.mediumSubtitle,
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
            fileImage: fileImage,
            uploading: uploading,
            uploaded: uploaded,
            error: error,
            progressColor: color.primary,
            errorProgressColor: color.systemNegative,
            progressBackgroundColor: Color.lightGrey,
            removeButtonImage: Asset.uploadRemove.image,
            removeButtonColor: color.baseNormal
        )

        return FileUploadListStyle(item: upload)
    }

    private var fileDownload: ChatFileDownloadStyle {
        typealias Download = L10n.Chat.Download

        let fileImage = FileImageStyle(
            fileFont: font.subtitle,
            fileColor: color.baseLight,
            errorIcon: Asset.uploadError.image,
            errorIconColor: color.systemNegative,
            backgroundColor: color.primary,
            errorBackgroundColor: Color.lightGrey
        )
        let download = ChatFileDownloadStateStyle(
            text: Download.download,
            font: font.mediumSubtitle,
            textColor: color.baseDark,
            infoFont: font.caption,
            infoColor: color.baseNormal
        )
        let downloading = ChatFileDownloadStateStyle(
            text: Download.downloading,
            font: font.mediumSubtitle,
            textColor: color.baseDark,
            infoFont: font.caption,
            infoColor: color.baseNormal
        )
        let open = ChatFileDownloadStateStyle(
            text: Download.open,
            font: font.mediumSubtitle,
            textColor: color.baseDark,
            infoFont: font.caption,
            infoColor: color.baseNormal
        )
        let error = ChatFileDownloadErrorStateStyle(
            text: Download.failed,
            font: font.mediumSubtitle,
            textColor: color.systemNegative,
            infoFont: font.caption,
            infoColor: color.baseNormal,
            separatorText: Download.Failed.separator,
            separatorFont: font.subtitle,
            separatorTextColor: color.baseDark,
            retryText: Download.Failed.retry,
            retryFont: font.mediumSubtitle,
            retryTextColor: color.baseDark
        )

        return ChatFileDownloadStyle(
            fileImage: fileImage,
            download: download,
            downloading: downloading,
            open: open,
            error: error,
            progressColor: color.primary,
            errorProgressColor: color.systemNegative,
            progressBackgroundColor: Color.lightGrey,
            backgroundColor: .white,
            borderColor: Color.lightGrey
        )
    }

    private var pickMedia: ItemListStyle {
        typealias Chat = L10n.Chat.PickMedia

        let itemFont = font.buttonLabel
        let itemFontColor = color.baseDark
        let itemIconColor = color.baseDark

        let pickPhoto = ListItemStyle(
            kind: .photoLibrary,
            title: Chat.photo,
            titleFont: itemFont,
            titleColor: itemFontColor,
            icon: Asset.photoLibraryIcon.image,
            iconColor: itemIconColor
        )
        let takePhoto = ListItemStyle(
            kind: .takePhoto,
            title: Chat.takePhoto,
            titleFont: itemFont,
            titleColor: itemFontColor,
            icon: Asset.cameraIcon.image,
            iconColor: itemIconColor
        )
        let browse = ListItemStyle(
            kind: .browse,
            title: Chat.browse,
            titleFont: itemFont,
            titleColor: itemFontColor,
            icon: Asset.browseIcon.image,
            iconColor: itemIconColor
        )

        return ItemListStyle(
            items: [pickPhoto, takePhoto, browse],
            separatorColor: color.baseShade,
            backgroundColor: Color.lightGrey
        )
    }
}
