import Foundation

extension Theme {
    /// Default style for confirmation screen in secure conversation. Be aware it depends on
    /// `self.colors` (ThemeColor).
    var defaultSecureConversationsConfirmationStyle: SecureConversations.ConfirmationStyle {
        typealias Confirmation = L10n.MessageCenter.Confirmation

        let chatStyle = chatStyle
        var header = chatStyle.header
        header.backButton = nil

        let titleStyle = SecureConversations.ConfirmationStyle.TitleStyle(
            text: Confirmation.title,
            font: font.header1,
            color: color.baseDark,
            accessibility: .init(isFontScalingEnabled: true)
        )

        let subtitleStyle = SecureConversations.ConfirmationStyle.SubtitleStyle(
            text: Confirmation.subtitle,
            font: font.bodyText,
            color: color.baseDark,
            accessibility: .init(isFontScalingEnabled: true)
        )

        let checkMessagesButtonStyle = SecureConversations.ConfirmationStyle.CheckMessagesButtonStyle(
            title: Confirmation.checkMessages,
            font: font.bodyText,
            textColor: color.baseLight,
            backgroundColor: color.primary,
            accessibility: .init(
                isFontScalingEnabled: true,
                label: Confirmation.Accessibility.checkMessagesLabel,
                hint: Confirmation.Accessibility.checkMessagesHint
            )
        )

        return .init(
            header: header,
            headerTitle: Confirmation.header,
            confirmationImage: Asset.mcEnvelope.image,
            confirmationImageTint: color.primary,
            titleStyle: titleStyle,
            subtitleStyle: subtitleStyle,
            checkMessagesButtonStyle: checkMessagesButtonStyle, backgroundColor: color.baseLight)
    }
}
