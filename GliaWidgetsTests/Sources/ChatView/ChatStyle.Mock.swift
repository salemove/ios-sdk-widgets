import UIKit
@testable import GliaWidgets

extension ChatStyle {
    static func mock(
        header: HeaderStyle = .mock(),
        connect: ConnectStyle = .mock(),
        backgroundColor: ColorType = .fill(color: .clear),
        preferredStatusBarStyle: UIStatusBarStyle = .default,
        title: String = "",
        visitorMessageStyle: Theme.VisitorMessageStyle = .mock(),
        operatorMessageStyle: Theme.OperatorMessageStyle = .mock(),
        choiceCardStyle: Theme.ChoiceCardStyle = .mock(),
        messageEntry: ChatMessageEntryStyle = .mock(),
        audioUpgrade: ChatCallUpgradeStyle = .mock(),
        videoUpgrade: ChatCallUpgradeStyle = .mock(),
        callBubble: BubbleStyle = .mock(),
        pickMedia: AttachmentSourceListStyle = .mock(),
        unreadMessageIndicator: UnreadMessageIndicatorStyle = .mock(),
        operatorTypingIndicator: OperatorTypingIndicatorStyle = .mock(),
        secureTranscriptTitle: String = "",
        secureTranscriptHeader: HeaderStyle = .mock(),
        unreadMessageDivider: UnreadMessageDividerStyle = .mock(),
        systemMessageStyle: Theme.SystemMessageStyle = .mock(),
        gliaVirtualAssistant: GliaVirtualAssistantStyle = .mock()
    ) -> ChatStyle {
        ChatStyle.init(
            header: header,
            connect: connect,
            backgroundColor: backgroundColor,
            preferredStatusBarStyle: preferredStatusBarStyle,
            title: title,
            visitorMessageStyle: visitorMessageStyle,
            operatorMessageStyle: operatorMessageStyle,
            choiceCardStyle: choiceCardStyle,
            messageEntry: messageEntry,
            audioUpgrade: audioUpgrade,
            videoUpgrade: videoUpgrade,
            callBubble: callBubble,
            pickMedia: pickMedia,
            unreadMessageIndicator: unreadMessageIndicator,
            operatorTypingIndicator: operatorTypingIndicator,
            secureTranscriptTitle: secureTranscriptTitle,
            secureTranscriptHeader: secureTranscriptHeader,
            unreadMessageDivider: unreadMessageDivider,
            systemMessageStyle: systemMessageStyle,
            gliaVirtualAssistant: gliaVirtualAssistant
        )
    }
}
extension ConnectStyle {
    static func mock(
        queueOperator: ConnectOperatorStyle = .mock,
        queue: ConnectStatusStyle = .mock(),
        connecting: ConnectStatusStyle = .mock(),
        connected: ConnectStatusStyle = .mock(),
        transferring: ConnectStatusStyle = .mock(),
        onHold: ConnectStatusStyle = .mock()
    ) -> ConnectStyle {
        return .init(
            queueOperator: queueOperator,
            queue: queue,
            connecting: connecting,
            connected: connected,
            transferring: transferring,
            onHold: onHold
        )
    }
}

extension ConnectStatusStyle {
    static func mock(
        firstText: String? = nil,
        firstTextFont: UIFont = .systemFont(ofSize: 16),
        firstTextFontColor: UIColor = .black,
        firstTextStyle: UIFont.TextStyle = .body,
        secondText: String? = nil,
        secondTextFont: UIFont = .systemFont(ofSize: 16),
        secondTextFontColor: UIColor = .black,
        secondTextStyle: UIFont.TextStyle = .body
    ) -> ConnectStatusStyle {
        return .init(
            firstText: firstText,
            firstTextFont: firstTextFont,
            firstTextFontColor: firstTextFontColor,
            firstTextStyle: firstTextStyle,
            secondText: secondText,
            secondTextFont: secondTextFont,
            secondTextFontColor: secondTextFontColor,
            secondTextStyle: secondTextStyle
        )
    }
}

extension Theme.VisitorMessageStyle {
    static func mock(
        text: Theme.Text = .mock(),
        background: Theme.Layer = .mock(),
        imageFile: ChatImageFileContentStyle = .mock(),
        fileDownload: ChatFileDownloadStyle = .mock(),
        status: Theme.Text = .mock(),
        delivered: String = ""
    ) -> Theme.VisitorMessageStyle {
        return .init(
            text: text,
            background: background,
            imageFile: imageFile,
            fileDownload: fileDownload,
            status: status,
            delivered: delivered
        )
    }
}

extension Theme.Text {
    static func mock(
        color: String = "",
        font: UIFont = .systemFont(ofSize: 16),
        textStyle: UIFont.TextStyle = .body,
        accessibility: Accessibility = .unsupported
    ) -> Theme.Text {
        return .init(
            color: color,
            font: font,
            textStyle: textStyle,
            accessibility: accessibility
        )
    }
}

extension Theme.Layer {
    static func mock(
        background: ColorType? = nil,
        borderColor: CGColor = .clear,
        borderWidth: CGFloat = 0,
        cornerRadius: CGFloat = 0
    ) -> Theme.Layer {
        return .init(
            background: background,
            borderColor: borderColor,
            borderWidth: borderWidth,
            cornerRadius: cornerRadius
        )
    }
}

extension ChatImageFileContentStyle {
    static func mock(
        backgroundColor: UIColor = .white
    ) -> ChatImageFileContentStyle {
        return .init(backgroundColor: backgroundColor)
    }
}

extension ChatFileDownloadStyle {
    static func mock(
        filePreview: FilePreviewStyle = .mock,
        download: ChatFileDownloadStateStyle = .mock(),
        downloading: ChatFileDownloadStateStyle = .mock(),
        open: ChatFileDownloadStateStyle = .mock(),
        error: ChatFileDownloadErrorStateStyle = .mock(),
        progressColor: UIColor = .red,
        errorProgressColor: UIColor = .red,
        progressBackgroundColor: UIColor = .red,
        backgroundColor: UIColor = .white,
        borderColor: UIColor = .clear
    ) -> ChatFileDownloadStyle {
        return .init(
            filePreview: filePreview,
            download: download,
            downloading: downloading,
            open: open,
            error: error,
            progressColor: progressColor,
            errorProgressColor: errorProgressColor,
            progressBackgroundColor: progressBackgroundColor,
            backgroundColor: backgroundColor,
            borderColor: borderColor
        )
    }
}

extension ChatFileDownloadStateStyle {
    static func mock(
        text: String = "",
        font: UIFont = .systemFont(ofSize: 16),
        textColor: UIColor = .black,
        textStyle: UIFont.TextStyle = .body,
        infoFont: UIFont = .systemFont(ofSize: 16),
        infoColor: UIColor = .red,
        infoTextStyle: UIFont.TextStyle = .body
    ) -> ChatFileDownloadStateStyle {
        return .init(
            text: text,
            font: font,
            textColor: textColor,
            textStyle: textStyle,
            infoFont: infoFont,
            infoColor: infoColor,
            infoTextStyle: infoTextStyle
        )
    }
}

extension ChatFileDownloadErrorStateStyle {
    static func mock(
        text: String = "",
        font: UIFont = .systemFont(ofSize: 16),
        textColor: UIColor = .black,
        textStyle: UIFont.TextStyle = .body,
        infoFont: UIFont = .systemFont(ofSize: 16),
        infoColor: UIColor = .black,
        infoTextStyle: UIFont.TextStyle = .body,
        separatorText: String = "",
        separatorFont: UIFont = .systemFont(ofSize: 16),
        separatorTextColor: UIColor = .black,
        separatorTextStyle: UIFont.TextStyle = .body,
        retryText: String = "",
        retryFont: UIFont = .systemFont(ofSize: 16),
        retryTextColor: UIColor = .black,
        retryTextStyle: UIFont.TextStyle = .body
    ) -> ChatFileDownloadErrorStateStyle {
        return .init(
            text: text,
            font: font,
            textColor: textColor,
            textStyle: textStyle,
            infoFont: infoFont,
            infoColor: infoColor,
            infoTextStyle: infoTextStyle,
            separatorText: separatorText,
            separatorFont: separatorFont,
            separatorTextColor: separatorTextColor,
            separatorTextStyle: separatorTextStyle,
            retryText: retryText,
            retryFont: retryFont,
            retryTextColor: retryTextColor,
            retryTextStyle: retryTextStyle
        )
    }
}

extension Theme.OperatorMessageStyle {
    static func mock(
        text: Theme.Text = .mock(),
        background: Theme.Layer = .mock(),
        imageFile: ChatImageFileContentStyle = .mock(),
        fileDownload: ChatFileDownloadStyle = .mock(),
        operatorImage: UserImageStyle = .mock()
    ) -> Theme.OperatorMessageStyle {
        return .init(
            text: text,
            background: background,
            imageFile: imageFile,
            fileDownload: fileDownload,
            operatorImage: operatorImage
        )
    }
}

extension Theme.ChoiceCardStyle {
    static func mock(
        text: Theme.Text = .mock(),
        background: Theme.Layer = .mock(),
        imageFile: ChatImageFileContentStyle = .mock(),
        fileDownload: ChatFileDownloadStyle = .mock(),
        operatorImage: UserImageStyle = .mock(),
        choiceOption: Option = .mock()
    ) -> Theme.ChoiceCardStyle {
        return .init(
            text: text,
            background: background,
            imageFile: imageFile,
            fileDownload: fileDownload,
            operatorImage: operatorImage,
            choiceOption: choiceOption
        )
    }
}

extension Theme.ChoiceCardStyle.Option {
    static func mock(
        normal: Theme.Button = .mock(),
        selected: Theme.Button = .mock(),
        disabled: Theme.Button = .mock()
    ) -> Theme.ChoiceCardStyle.Option {
        return .init(
            normal: normal,
            selected: selected,
            disabled: disabled
        )
    }
}

extension Theme.Button {
    static func mock(
        background: ColorType = .fill(color: .white),
        title: Theme.Text = .mock(),
        cornerRadius: CGFloat = 0,
        borderWidth: CGFloat = 0,
        borderColor: String? = nil,
        shadow: Theme.Shadow = .standard,
        accessibility: Accessibility = .unsupported
    ) -> Theme.Button {
        return .init(
            background: background,
            title: title,
            cornerRadius: cornerRadius,
            borderWidth: borderWidth,
            borderColor: borderColor,
            shadow: shadow,
            accessibility: accessibility
        )
    }
}

extension ChatMessageEntryStyle {
    static func mock(
        messageFont: UIFont = .systemFont(ofSize: 16),
        messageColor: UIColor = .black,
        enterMessagePlaceholder: String = "",
        startEngagementPlaceholder: String = "",
        choiceCardPlaceholder: String = "",
        placeholderFont: UIFont = .systemFont(ofSize: 16),
        placeholderColor: UIColor = .black,
        separatorColor: UIColor = .black,
        backgroundColor: UIColor = .white,
        mediaButton: MessageButtonStyle = .mock(),
        sendButton: MessageButtonStyle = .mock(),
        uploadList: FileUploadListStyle = .mock
    ) -> ChatMessageEntryStyle {
        return .init(
            messageFont: messageFont,
            messageColor: messageColor,
            enterMessagePlaceholder: enterMessagePlaceholder,
            startEngagementPlaceholder: startEngagementPlaceholder,
            choiceCardPlaceholder: choiceCardPlaceholder,
            placeholderFont: placeholderFont,
            placeholderColor: placeholderColor,
            separatorColor: separatorColor,
            backgroundColor: backgroundColor,
            mediaButton: mediaButton,
            sendButton: sendButton,
            uploadList: uploadList
        )
    }
}

extension MessageButtonStyle {
    static func mock(
        image: UIImage = .mock,
        color: UIColor = .black
    ) -> MessageButtonStyle {
        return .init(
            image: image,
            color: color
        )
    }
}

extension ChatCallUpgradeStyle {
    static func mock(
        icon: UIImage = .mock,
        iconColor: UIColor = .black,
        text: String = "",
        textFont: UIFont = .systemFont(ofSize: 16),
        textColor: UIColor = .black,
        durationFont: UIFont = .systemFont(ofSize: 16),
        durationColor: UIColor = .black,
        borderColor: UIColor = .clear
    ) -> ChatCallUpgradeStyle {
        return .init(
            icon: icon,
            iconColor: iconColor,
            text: text,
            textFont: textFont,
            textColor: textColor,
            durationFont: durationFont,
            durationColor: durationColor,
            borderColor: borderColor
        )
    }
}

extension UnreadMessageIndicatorStyle {
    static func mock(
        badgeFont: UIFont = .systemFont(ofSize: 16),
        badgeTextColor: UIColor = .white,
        badgeColor: ColorType = .fill(color: .black),
        placeholderImage: UIImage? = nil,
        placeholderColor: UIColor = .black,
        placeholderBackgroundColor: ColorType = .fill(color: .black),
        imageBackgroundColor: ColorType = .fill(color: .black),
        transferringImage: UIImage = .mock
    ) -> UnreadMessageIndicatorStyle {
        return .init(
            badgeFont: badgeFont,
            badgeTextColor: badgeTextColor,
            badgeColor: badgeColor,
            placeholderImage: placeholderImage,
            placeholderColor: placeholderColor,
            placeholderBackgroundColor: placeholderBackgroundColor,
            imageBackgroundColor: imageBackgroundColor,
            transferringImage: transferringImage
        )
    }
}

extension OperatorTypingIndicatorStyle {
    static func mock(
        color: UIColor = .red
    ) -> OperatorTypingIndicatorStyle {
        return .init(color: color)
    }
}

extension UnreadMessageDividerStyle {
    static func mock(
        title: String = "",
        titleColor: UIColor = .black,
        titleFont: UIFont = .systemFont(ofSize: 16),
        lineColor: UIColor = .black,
        accessibility: Accessibility = .unsupported
    ) -> UnreadMessageDividerStyle {
        return .init(
            title: title,
            titleColor: titleColor,
            titleFont: titleFont,
            lineColor: lineColor,
            accessibility: accessibility
        )
    }
}

extension Theme.SystemMessageStyle {
    static func mock(
        text: Theme.Text = .mock(),
        background: Theme.Layer = .mock(),
        imageFile: ChatImageFileContentStyle = .mock(),
        fileDownload: ChatFileDownloadStyle = .mock()
    ) -> Theme.SystemMessageStyle {
        return .init(
            text: text,
            background: background,
            imageFile: imageFile,
            fileDownload: fileDownload
        )
    }
}

extension GliaVirtualAssistantStyle {
    static func mock(
        persistentButton: GvaPersistentButtonStyle = .mock(),
        quickReplyButton: GvaQuickReplyButtonStyle = .mock(),
        galleryList: GvaGalleryListViewStyle = .initial
    ) -> GliaVirtualAssistantStyle {
        return .init(
            persistentButton: persistentButton,
            quickReplyButton: quickReplyButton,
            galleryList: galleryList
        )
    }
}

extension GvaPersistentButtonStyle {
    static func mock(
        title: Theme.ChatTextContentStyle = .mock(),
        backgroundColor: ColorType = .fill(color: .white),
        cornerRadius: CGFloat = 0,
        borderWidth: CGFloat = 0,
        borderColor: UIColor = .clear,
        button: ButtonStyle = .mock()
    ) -> GvaPersistentButtonStyle {
        return .init(
            title: title,
            backgroundColor: backgroundColor,
            cornerRadius: cornerRadius,
            borderWidth: borderWidth,
            borderColor: borderColor,
            button: button
        )
    }
}

extension GvaQuickReplyButtonStyle {
    static func mock(
        textFont: UIFont = .systemFont(ofSize: 16),
        textColor: UIColor = .black,
        backgroundColor: ColorType = .fill(color: .white),
        cornerRadius: CGFloat = 0,
        borderColor: UIColor = .clear,
        borderWidth: CGFloat = 0
    ) -> GvaQuickReplyButtonStyle {
        return .init(
            textFont: textFont,
            textColor: textColor,
            backgroundColor: backgroundColor,
            cornerRadius: cornerRadius,
            borderColor: borderColor,
            borderWidth: borderWidth
        )
    }
}

extension GvaPersistentButtonStyle.ButtonStyle {
    static func mock(
        textFont: UIFont = .systemFont(ofSize: 16),
        textColor: UIColor = .black,
        backgroundColor: ColorType = .fill(color: .white),
        cornerRadius: CGFloat = 0,
        borderColor: UIColor = .clear,
        borderWidth: CGFloat = 0
    ) -> GvaPersistentButtonStyle.ButtonStyle {
        return .init(
            textFont: textFont,
            textColor: textColor,
            backgroundColor: backgroundColor,
            cornerRadius: cornerRadius,
            borderColor: borderColor,
            borderWidth: borderWidth
        )
    }
}

extension Theme.ChatTextContentStyle {
    static func mock(
        text: Theme.Text = .mock(),
        background: Theme.Layer = .mock()
    ) -> Theme.ChatTextContentStyle {
        return .init(
            text: text,
            background: background
        )
    }
}
