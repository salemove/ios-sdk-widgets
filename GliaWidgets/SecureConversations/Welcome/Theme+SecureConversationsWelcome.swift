extension Theme {
    var secureConversationsWelcomeStyle: SecureConversations.WelcomeStyle {
        let chat = chatStyle

        let welcomeTitleStyle = SecureConversations.WelcomeStyle.TitleStyle(
            text: "Welcome to Message Center",
            font: font.header3,
            color: .black
        )

        let welcomeSubtitleStyle = SecureConversations.WelcomeStyle.SubtitleStyle(
            text: "Send a message and we’ll get back to you within 48 hours",
            font: font.subtitle,
            color: .black
        )

        let checkMessagesButtonStyle = SecureConversations.WelcomeStyle.CheckMessagesButtonStyle(
            title: "Check messages",
            font: font.header2,
            color: color.primary
        )

        let messageTitleStyle = SecureConversations.WelcomeStyle.MessageTitleStyle(
            title: "Your message",
            font: font.mediumSubtitle1,
            color: .black
        )

        let messageTextViewStyle = SecureConversations.WelcomeStyle.MessageTextViewStyle(
            placeholderText: "Enter your message",
            placeholderFont: font.bodyText,
            placeholderColor: color.baseNormal,
            textFont: font.bodyText,
            textColor: .black,
            borderColor: color.baseNormal,
            activeBorderColor: color.primary,
            borderWidth: 1,
            cornerRadius: 4
        )

        let sendButtonStyle = SecureConversations.WelcomeStyle.SendButtonStyle(
            title: "Send",
            font: font.bodyText,
            textColor: color.baseLight,
            backgroundColor: color.primary
        )

        return .init(
            header: chat.header,
            headerTitle: "Messaging",
            welcomeTitleStyle: welcomeTitleStyle,
            welcomeSubtitleStyle: welcomeSubtitleStyle,
            checkMessagesButtonStyle: checkMessagesButtonStyle,
            messageTitleStyle: messageTitleStyle,
            messageTextViewStyle: messageTextViewStyle,
            sendButtonStyle: sendButtonStyle,
            backgroundColor: color.background
        )
    }
}
