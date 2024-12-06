import UIKit

extension Theme {
    var entryWidgetStyle: EntryWidgetStyle {
        let loading: EntryWidgetStyle.MediaTypeItemStyle.LoadingStyle = .init(
            loadingTintColor: .fill(color: color.baseShade),
            accessibility: .init(label: Localization.EntryWidget.Loading.Accessibility.label)
        )

        let mediaTypeAccessibility: EntryWidgetStyle.MediaTypeItemStyle.Accessibility = .init(
            chatHint: Localization.EntryWidget.LiveChat.Button.Accessibility.hint,
            audioHint: Localization.EntryWidget.Audio.Button.Accessibility.hint,
            videoHint: Localization.EntryWidget.Video.Button.Accessibility.hint,
            secureMessagingHint: Localization.EntryWidget.SecureMessaging.Button.Accessibility.hint
        )

        let mediaTypeItem: EntryWidgetStyle.MediaTypeItemStyle = .init(
            chatTitle: Localization.EntryWidget.LiveChat.Button.label,
            audioTitle: Localization.EntryWidget.Audio.Button.label,
            videoTitle: Localization.EntryWidget.Video.Button.label,
            secureMessagingTitle: Localization.EntryWidget.SecureMessaging.Button.label,
            titleFont: font.bodyText,
            titleColor: color.baseDark,
            titleTextStyle: .body,
            chatMessage: Localization.EntryWidget.LiveChat.Button.description,
            audioMessage: Localization.EntryWidget.Audio.Button.description,
            videoMessage: Localization.EntryWidget.Video.Button.description,
            secureMessagingMessage: Localization.EntryWidget.SecureMessaging.Button.description,
            messageFont: font.caption,
            messageColor: color.baseNormal,
            unreadMessagesCounterFont: font.caption,
            unreadMessagesCounterColor: color.baseLight,
            unreadMessagesCounterBackgroundColor: .fill(color: color.primary),
            messageTextStyle: .caption1,
            iconColor: .fill(color: color.primary),
            backgroundColor: .fill(color: color.baseLight),
            loading: loading,
            accessibility: mediaTypeAccessibility
        )

        let backgroundColor: ColorType = .fill(color: color.baseLight)

        let poweredBy = PoweredByStyle(
            text: Localization.General.powered,
            font: font.caption,
            accessibility: .init(isFontScalingEnabled: true)
        )

        let errorButton: ActionButtonStyle = .init(
            title: Localization.EntryWidget.ErrorState.TryAgain.Button.label,
            titleFont: font.bodyText,
            titleColor: color.primary,
            backgroundColor: .fill(color: color.baseLight),
            shadowColor: .clear
        )

        let style: EntryWidgetStyle = .init(
            mediaTypeItem: mediaTypeItem,
            backgroundColor: backgroundColor,
            cornerRadius: 24,
            poweredBy: poweredBy,
            dividerColor: color.baseNeutral,
            errorTitle: Localization.EntryWidget.ErrorState.title,
            errorTitleFont: font.header3,
            errorTitleStyle: .body,
            errorTitleColor: color.baseDark,
            errorMessage: Localization.EntryWidget.ErrorState.description,
            errorMessageFont: font.bodyText,
            errorMessageStyle: .body,
            errorMessageColor: color.baseNormal,
            errorButton: errorButton,
            offlineTitle: Localization.EntryWidget.EmptyState.title,
            offlineMessage: Localization.EntryWidget.EmptyState.description
        )

        return style
    }
}
