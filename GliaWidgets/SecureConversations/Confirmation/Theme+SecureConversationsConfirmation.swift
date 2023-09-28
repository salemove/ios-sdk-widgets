import Foundation

extension Theme {
    /// Default style for confirmation screen in secure conversation. Be aware it depends on
    /// `self.colors` (ThemeColor).
    var defaultSecureConversationsConfirmationStyle: SecureConversations.ConfirmationStyle {
        let chatStyle = chatStyle
        var header = chatStyle.header
        header.backButton = nil

        let titleStyle = SecureConversations.ConfirmationStyle.TitleStyle(
            text: Localization.General.thankYou,
            font: font.header1,
            color: color.baseDark,
            accessibility: .init(isFontScalingEnabled: true)
        )

        let subtitleStyle = SecureConversations.ConfirmationStyle.SubtitleStyle(
            text: Localization.MessageCenter.Confirmation.subtitle,
            font: font.bodyText,
            color: color.baseDark,
            accessibility: .init(isFontScalingEnabled: true)
        )

        let checkMessagesButtonStyle = SecureConversations.ConfirmationStyle.CheckMessagesButtonStyle(
            title: Localization.MessageCenter.Welcome.checkMessages,
            font: font.bodyText,
            textColor: color.baseLight,
            backgroundColor: color.primary,
            accessibility: .init(
                isFontScalingEnabled: true,
                label: Localization.MessageCenter.Confirmation.CheckMessages.Accessibility.label,
                hint: Localization.MessageCenter.Confirmation.CheckMessages.Accessibility.hint
            )
        )

        return .init(
            header: header,
            headerTitle: Localization.MessageCenter.header,
            confirmationImage: Asset.mcEnvelope.image,
            confirmationImageTint: color.primary,
            titleStyle: titleStyle,
            subtitleStyle: subtitleStyle,
            checkMessagesButtonStyle: checkMessagesButtonStyle, backgroundColor: color.baseLight)
    }
}
