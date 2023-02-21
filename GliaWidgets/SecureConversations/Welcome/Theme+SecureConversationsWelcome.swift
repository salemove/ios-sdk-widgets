import UIKit

extension Theme {
    var secureConversationsWelcomeStyle: SecureConversations.WelcomeStyle {
        typealias Welcome = L10n.MessageCenter.Welcome
        let chat = chatStyle

        var header = chat.header
        header.backButton = nil

        let welcomeTitleStyle = SecureConversations.WelcomeStyle.TitleStyle(
            text: Welcome.title,
            font: font.header3,
            textStyle: .title3,
            color: .black,
            accessibility: .init(isFontScalingEnabled: true)
        )

        let welcomeSubtitleStyle = SecureConversations.WelcomeStyle.SubtitleStyle(
            text: Welcome.subtitle,
            font: font.subtitle,
            textStyle: .footnote,
            color: .black,
            accessibility: .init(isFontScalingEnabled: true)
        )

        let checkMessagesButtonStyle = SecureConversations.WelcomeStyle.CheckMessagesButtonStyle(
            title: Welcome.checkMessages,
            font: font.header2,
            textStyle: .title2,
            color: color.primary,
            accessibility: .init(
                isFontScalingEnabled: true,
                label: Welcome.Accessibility.checkMessagesLabel,
                hint: Welcome.Accessibility.checkMessagesHint
            )
        )

        let messageTitleStyle = SecureConversations.WelcomeStyle.MessageTitleStyle(
            title: Welcome.messageTitle,
            font: font.mediumSubtitle1,
            textStyle: .subheadline,
            color: .black,
            accessibility: .init(isFontScalingEnabled: true)
        )

        let messageTextViewNormalStyle = SecureConversations.WelcomeStyle.MessageTextViewNormalStyle(
            placeholderText: Welcome.messageTextViewNormal,
            placeholderFont: font.bodyText,
            placeholderColor: color.baseNormal,
            textFont: font.bodyText,
            textFontStyle: .body,
            textColor: .black,
            borderColor: color.baseNormal,
            borderWidth: 1,
            cornerRadius: 4,
            backgroundColor: color.background,
            accessibility: .init(isFontScalingEnabled: true)
        )

        let messageTextViewActiveStyle = SecureConversations.WelcomeStyle.MessageTextViewActiveStyle(
            placeholderText: Welcome.messageTextViewActive,
            placeholderFont: font.bodyText,
            placeholderColor: color.baseNormal,
            textFont: font.bodyText,
            textFontStyle: .body,
            textColor: .black,
            borderColor: color.primary,
            borderWidth: 1,
            cornerRadius: 4,
            backgroundColor: color.background,
            accessibility: .init(isFontScalingEnabled: true)
        )

        let messageTextViewDisabledStyle = SecureConversations.WelcomeStyle.MessageTextViewDisabledStyle(
            placeholderText: Welcome.messageTextViewDisabled,
            placeholderFont: font.bodyText,
            placeholderColor: color.baseNormal,
            textFont: font.bodyText,
            textFontStyle: .body,
            textColor: .black,
            borderColor: .disabledBorder,
            borderWidth: 1,
            cornerRadius: 4,
            backgroundColor: .disabledBackground,
            accessibility: .init(isFontScalingEnabled: true)
        )

        let messageTextViewStyle = SecureConversations.WelcomeStyle.MessageTextViewStyle(
            normalStyle: messageTextViewNormalStyle,
            disabledStyle: messageTextViewDisabledStyle,
            activeStyle: messageTextViewActiveStyle
        )

        let sendButtonEnabledStyle = SecureConversations.WelcomeStyle.SendButtonEnabledStyle(
            title: Welcome.sendEnabled,
            font: font.bodyText,
            textStyle: .body,
            textColor: color.baseLight,
            backgroundColor: color.primary,
            borderColor: .clear,
            borderWidth: 1,
            cornerRadius: 4,
            accessibility: .init(
                isFontScalingEnabled: true,
                label: Welcome.Accessibility.sendLabel,
                hint: Welcome.Accessibility.sendHint
            )
        )

        let sendButtonDisabledStyle = SecureConversations.WelcomeStyle.SendButtonDisabledStyle(
            title: Welcome.sendDisabled,
            font: font.bodyText,
            textStyle: .body,
            textColor: .disabledTitle,
            backgroundColor: .disabledBackground,
            borderColor: .disabledBorder,
            borderWidth: 1,
            cornerRadius: 4,
            accessibility: .init(
                isFontScalingEnabled: true,
                label: Welcome.Accessibility.sendLabel,
                hint: Welcome.Accessibility.sendHint
            )
        )

        let sendButtonLoadingStyle = SecureConversations.WelcomeStyle.SendButtonLoadingStyle(
            title: Welcome.sendLoading,
            font: font.bodyText,
            textStyle: .body,
            textColor: .disabledTitle,
            backgroundColor: .disabledBackground,
            borderColor: .disabledBorder,
            borderWidth: 1,
            activityIndicatorColor: .disabledActivityIndicator,
            cornerRadius: 4,
            accessibility: .init(
                isFontScalingEnabled: true,
                label: Welcome.Accessibility.sendLabel,
                hint: Welcome.Accessibility.sendHint
            )
        )

        let sendButtonStyle = SecureConversations.WelcomeStyle.SendButtonStyle(
            enabledStyle: sendButtonEnabledStyle,
            disabledStyle: sendButtonDisabledStyle,
            loadingStyle: sendButtonLoadingStyle
        )

        let messageWarningStyle = SecureConversations.WelcomeStyle.MessageWarningStyle(
            textColor: color.systemNegative,
            textFont: .systemFont(ofSize: 12.0),
            textStyle: .caption1,
            iconColor: color.systemNegative,
            messageLengthLimitText: L10n.MessageCenter.Welcome.messageLengthWarning,
            accessibility: .init(isFontScalingEnabled: true)
        )

        let filePickerButtonStyle = SecureConversations.WelcomeStyle.FilePickerButtonStyle(
            color: .gray,
            disabledColor: .lightGray,
            accessibility: .init(
                isFontScalingEnabled: true,
                accessibilityLabel: Welcome.Accessibility.filePickerLabel,
                accessibilityHint: Welcome.Accessibility.filePickerHint
            )
        )

        let titleImageStyle = SecureConversations.WelcomeStyle.TitleImageStyle(
            color: color.primary,
            accessibility: .unsupported
        )

        var uploadListStyle: MessageCenterFileUploadListStyle {
            // TODO: Introduce dedicated localization for Secure conversations upload list instaed of using Chat's one.
            // MOB-1831
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
            let upload = MessageCenterFileUploadStyle(
                filePreview: filePreview,
                uploading: uploading,
                uploaded: uploaded,
                error: error,
                progressColor: color.primary,
                errorProgressColor: color.systemNegative,
                progressBackgroundColor: Color.lightGrey,
                removeButtonImage: Asset.mcRemoveUpload.image,
                removeButtonColor: color.baseNormal,
                backgroundColor: .commonGray,
                accessibility: .init(
                    removeButtonAccessibilityLabel: Accessibility.RemoveUpload.label,
                    progressPercentValue: Accessibility.Progress.percentValue,
                    fileNameWithProgressValue: Accessibility.Progress.fileNameWithProgressValue,
                    isFontScalingEnabled: true
                )
            )

            return MessageCenterFileUploadListStyle(item: upload)
        }

        // TODO: Introduce dedicated localization for Secure conversations upload list instaed of using Chat's one.
        // MOB-1831
        var pickMediaStyle: AttachmentSourceListStyle {
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

        return .init(
            header: header,
            headerTitle: Welcome.header,
            welcomeTitleStyle: welcomeTitleStyle,
            titleImageStyle: titleImageStyle,
            welcomeSubtitleStyle: welcomeSubtitleStyle,
            checkMessagesButtonStyle: checkMessagesButtonStyle,
            messageTitleStyle: messageTitleStyle,
            messageTextViewStyle: messageTextViewStyle,
            sendButtonStyle: sendButtonStyle,
            messageWarningStyle: messageWarningStyle,
            filePickerButtonStyle: filePickerButtonStyle,
            attachmentListStyle: uploadListStyle,
            pickMediaStyle: pickMediaStyle,
            backgroundColor: color.background
        )
    }
}

private extension UIColor {
    // Variations of gray color indicating disabled state of components.
    static let disabledBackground = commonGray
    static let disabledBorder = UIColor(red: 0.424, green: 0.463, blue: 0.514, alpha: 0.5)
    static let disabledTitle = UIColor(red: 0, green: 0, blue: 0, alpha: 0.4)
    static let disabledActivityIndicator = UIColor(red: 0.769, green: 0.769, blue: 0.769, alpha: 1)
}

private extension UIColor {
    static let commonGray = UIColor(red: 0.953, green: 0.953, blue: 0.953, alpha: 1)
}
