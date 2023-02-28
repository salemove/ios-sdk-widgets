import Foundation

extension Theme {
    var secureConversationsConfirmationStyle: SecureConversations.ConfirmationStyle {
        typealias Confirmation = L10n.MessageCenter.Confirmation

        let chatStyle = chatStyle
        var header = chatStyle.header
        header.backButton = nil

        let titleStyle = SecureConversations.ConfirmationStyle.TitleStyle(
            text: Confirmation.title,
            font: font.header3,
            color: .black,
            accessibility: .init(isFontScalingEnabled: true)
        )

        let subtitleStyle = SecureConversations.ConfirmationStyle.SubtitleStyle(
            text: Confirmation.subtitle,
            font: font.bodyText,
            color: .black,
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
            titleStyle: titleStyle,
            subtitleStyle: subtitleStyle,
            checkMessagesButtonStyle: checkMessagesButtonStyle, backgroundColor: .white)
    }
}
