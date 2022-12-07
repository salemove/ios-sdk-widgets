extension Theme {
    var secureConversationsWelcomeStyle: SecureConversations.WelcomeStyle {
        let chat = chatStyle

        return .init(
            header: chat.header,
            title: "Messaging",
            welcomeTitle: "Welcome",
            welcomeDescription: "Description",
            backgroundColor: .white
        )
    }
}
