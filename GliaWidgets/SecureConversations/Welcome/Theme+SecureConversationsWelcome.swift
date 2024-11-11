import UIKit

extension Theme {
    var secureConversationsWelcomeStyle: SecureConversations.WelcomeStyle {
        typealias Welcome = Localization.MessageCenter.Welcome
        let chat = chatStyle

        var header = chat.header
        header.backButton = nil

        let welcomeTitleStyle = SecureConversations.WelcomeStyle.TitleStyle(
            text: Localization.MessageCenter.Welcome.title,
            font: font.header3,
            textStyle: .title3,
            color: .black,
            accessibility: .init(isFontScalingEnabled: true)
        )

        let welcomeSubtitleStyle = SecureConversations.WelcomeStyle.SubtitleStyle(
            text: Localization.MessageCenter.Welcome.subtitle,
            font: font.subtitle,
            textStyle: .footnote,
            color: .black,
            accessibility: .init(isFontScalingEnabled: true)
        )

        let checkMessagesButtonStyle = SecureConversations.WelcomeStyle.CheckMessagesButtonStyle(
            title: Localization.MessageCenter.Welcome.checkMessages,
            font: font.bodyText,
            textStyle: .body,
            color: color.primary,
            accessibility: .init(
                isFontScalingEnabled: true,
                label: Localization.MessageCenter.Welcome.checkMessages,
                hint: Localization.MessageCenter.Welcome.CheckMessages.Accessibility.hint
            )
        )

        let messageTitleStyle = SecureConversations.WelcomeStyle.MessageTitleStyle(
            title: Localization.MessageCenter.Welcome.messageTitle,
            font: font.mediumSubtitle1,
            textStyle: .headline,
            color: .black,
            accessibility: .init(isFontScalingEnabled: true)
        )

        let messageTextViewNormalStyle = SecureConversations.WelcomeStyle.MessageTextViewNormalStyle(
            placeholderText: Localization.MessageCenter.Welcome.MessageInput.placeholder,
            placeholderFont: font.bodyText,
            placeholderColor: color.baseNormal,
            textFont: font.bodyText,
            textFontStyle: .body,
            textColor: .black,
            borderColor: color.baseNormal,
            borderWidth: 1,
            cornerRadius: 4,
            backgroundColor: color.baseLight,
            accessibility: .init(isFontScalingEnabled: true)
        )

        let messageTextViewActiveStyle = SecureConversations.WelcomeStyle.MessageTextViewActiveStyle(
            placeholderText: Localization.MessageCenter.Welcome.MessageInput.placeholder,
            placeholderFont: font.bodyText,
            placeholderColor: color.baseNormal,
            textFont: font.bodyText,
            textFontStyle: .body,
            textColor: .black,
            borderColor: color.primary,
            borderWidth: 1,
            cornerRadius: 4,
            backgroundColor: color.baseLight,
            accessibility: .init(isFontScalingEnabled: true)
        )

        let messageTextViewDisabledStyle = SecureConversations.WelcomeStyle.MessageTextViewDisabledStyle(
            placeholderText: Localization.MessageCenter.Welcome.MessageInput.placeholder,
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
            title: Localization.General.send,
            font: font.bodyText,
            textStyle: .body,
            textColor: color.baseLight,
            backgroundColor: color.primary,
            borderColor: .clear,
            borderWidth: 1,
            cornerRadius: 4,
            accessibility: .init(
                isFontScalingEnabled: true,
                label: Localization.General.send,
                hint: Localization.MessageCenter.Welcome.Send.Accessibility.hint
            )
        )

        let sendButtonDisabledStyle = SecureConversations.WelcomeStyle.SendButtonDisabledStyle(
            title: Localization.General.send,
            font: font.bodyText,
            textStyle: .body,
            textColor: .disabledTitle,
            backgroundColor: .disabledBackground,
            borderColor: .disabledBorder,
            borderWidth: 1,
            cornerRadius: 4,
            accessibility: .init(
                isFontScalingEnabled: true,
                label: Localization.General.send,
                hint: Localization.MessageCenter.Welcome.Send.Accessibility.hint
            )
        )

        let sendButtonLoadingStyle = SecureConversations.WelcomeStyle.SendButtonLoadingStyle(
            title: Localization.General.send,
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
                label: Localization.General.send,
                hint: Localization.MessageCenter.Welcome.Send.Accessibility.hint
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
            messageLengthLimitText: Localization.MessageCenter.Welcome.MessageLength.error,
            accessibility: .init(isFontScalingEnabled: true)
        )

        let filePickerButtonStyle = SecureConversations.WelcomeStyle.FilePickerButtonStyle(
            color: .gray,
            disabledColor: .lightGray,
            accessibility: .init(
                isFontScalingEnabled: true,
                accessibilityLabel: Localization.MessageCenter.Welcome.FilePicker.Accessibility.label,
                accessibilityHint: Localization.MessageCenter.Welcome.FilePicker.Accessibility.hint
            )
        )

        let titleImageStyle = SecureConversations.WelcomeStyle.TitleImageStyle(
            color: color.primary,
            accessibility: .unsupported
        )

        var uploadListStyle: MessageCenterFileUploadListStyle {
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
            let upload = MessageCenterFileUploadStyle(
                filePreview: filePreview,
                uploading: uploading,
                uploaded: uploaded,
                error: error,
                progressColor: color.primary,
                errorProgressColor: color.systemNegative,
                progressBackgroundColor: color.baseNeutral,
                removeButtonImage: Asset.mcRemoveUpload.image,
                removeButtonColor: color.baseNormal,
                backgroundColor: .commonGray,
                accessibility: .init(
                    removeButtonAccessibilityLabel: Localization.Chat.File.RemoveUpload.Accessibility.label,
                    progressPercentValue: Localization.Templates.percentValue,
                    fileNameWithProgressValue: Localization.Templates.fileNameWithProgressValue,
                    isFontScalingEnabled: true
                )
            )

            return MessageCenterFileUploadListStyle(item: upload)
        }

        // TODO: Introduce dedicated localization for Secure conversations upload list instaed of using Chat's one.
        // MOB-1831
        var pickMediaStyle: AttachmentSourceListStyle {
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

        return .init(
            header: header,
            headerTitle: Localization.MessageCenter.header,
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
            backgroundColor: color.baseLight
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
