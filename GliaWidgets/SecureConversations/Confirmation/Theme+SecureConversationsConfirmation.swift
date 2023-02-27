import Foundation

extension Theme {
    var secureConversationsConfirmationStyle: SecureConversations.ConfirmationStyle {
        let chatStyle = chatStyle
        var header = chatStyle.header
        header.backButton = nil

        let titleStyle = SecureConversations.ConfirmationStyle.TitleStyle(
            text: "Thank you!",
            font: font.header3,
            color: .black
        )

        let subtitleStyle = SecureConversations.ConfirmationStyle.SubtitleStyle(
            text: "Your message has been sent.\nWe will get back to you within 48 hours.",
            font: font.bodyText,
            color: .black
        )

        let checkMessagesButtonStyle = SecureConversations.ConfirmationStyle.CheckMessagesButtonStyle(
            title: "Check messages",
            font: font.bodyText,
            textColor: color.baseLight,
            backgroundColor: color.primary
        )

        return .init(
            header: header,
            headerTitle: "Messaging",
            confirmationImage: Asset.mcEnvelope.image,
            titleStyle: titleStyle,
            subtitleStyle: subtitleStyle,
            checkMessagesButtonStyle: checkMessagesButtonStyle, backgroundColor: .white)
    }
}
