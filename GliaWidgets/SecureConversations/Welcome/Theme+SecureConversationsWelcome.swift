import UIKit

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

        let messageTextViewNormalStyle = SecureConversations.WelcomeStyle.MessageTextViewNormalStyle(
            placeholderText: "Enter your message",
            placeholderFont: font.bodyText,
            placeholderColor: color.baseNormal,
            textFont: font.bodyText,
            textColor: .black,
            borderColor: color.baseNormal,
            borderWidth: 1,
            cornerRadius: 4,
            backgroundColor: color.background
        )

        let messageTextViewActiveStyle = SecureConversations.WelcomeStyle.MessageTextViewActiveStyle(
            placeholderText: "Enter your message",
            placeholderFont: font.bodyText,
            placeholderColor: color.baseNormal,
            textFont: font.bodyText,
            textColor: .black,
            borderColor: color.primary,
            borderWidth: 1,
            cornerRadius: 4,
            backgroundColor: color.background
        )

        let messageTextViewDisabledStyle = SecureConversations.WelcomeStyle.MessageTextViewDisabledStyle(
            placeholderText: "Enter your message",
            placeholderFont: font.bodyText,
            placeholderColor: color.baseNormal,
            textFont: font.bodyText,
            textColor: .black,
            borderColor: .disabledBorder,
            borderWidth: 1,
            cornerRadius: 4,
            backgroundColor: .disabledBackground
        )

        let messageTextViewStyle = SecureConversations.WelcomeStyle.MessageTextViewStyle(
            normalStyle: messageTextViewNormalStyle,
            disabledStyle: messageTextViewDisabledStyle,
            activeStyle: messageTextViewActiveStyle
        )

        let sendButtonEnabledStyle = SecureConversations.WelcomeStyle.SendButtonEnabledStyle(
            title: "Send",
            font: font.bodyText,
            textColor: color.baseLight,
            backgroundColor: color.primary,
            borderColor: .clear,
            borderWidth: 1,
            cornerRadius: 4
        )

        let sendButtonDisabledStyle = SecureConversations.WelcomeStyle.SendButtonDisabledStyle(
            title: "Send",
            font: font.bodyText,
            textColor: .disabledTitle,
            backgroundColor: .disabledBackground,
            borderColor: .disabledBorder,
            borderWidth: 1,
            cornerRadius: 4
        )

        let sendButtonLoadingStyle = SecureConversations.WelcomeStyle.SendButtonLoadingStyle(
            title: "Send",
            font: font.bodyText,
            textColor: .disabledTitle,
            backgroundColor: .disabledBackground,
            borderColor: .disabledBorder,
            borderWidth: 1,
            activityIndicatorColor: .disabledActivityIndicator,
            cornerRadius: 4
        )

        let sendButtonStyle = SecureConversations.WelcomeStyle.SendButtonStyle(
            enabledStyle: sendButtonEnabledStyle,
            disabledStyle: sendButtonDisabledStyle,
            loadingStyle: sendButtonLoadingStyle
        )

        let messageWarningStyle = SecureConversations.WelcomeStyle.MessageWarningStyle(
            textColor: color.systemNegative,
            textFont: .systemFont(ofSize: 12.0),
            iconColor: color.systemNegative,
            messageLengthLimitText: L10n.MessageCenter.Welcome.messageLengthWarning
        )

        let filePickerButtonStyle = SecureConversations.WelcomeStyle.FilePickerButtonStyle(
            color: .gray,
            disabledColor: .lightGray
        )

        let titleImageStyle = SecureConversations.WelcomeStyle.TitleImageStyle(color: color.primary)

        return .init(
            header: chat.header,
            headerTitle: "Messaging",
            welcomeTitleStyle: welcomeTitleStyle,
            titleImageStyle: titleImageStyle,
            welcomeSubtitleStyle: welcomeSubtitleStyle,
            checkMessagesButtonStyle: checkMessagesButtonStyle,
            messageTitleStyle: messageTitleStyle,
            messageTextViewStyle: messageTextViewStyle,
            sendButtonStyle: sendButtonStyle,
            messageWarningStyle: messageWarningStyle,
            filePickerButtonStyle: filePickerButtonStyle,
            backgroundColor: color.background
        )
    }
}

private extension UIColor {
    // Variations of gray color indicating disabled state of components.
    static let disabledBackground = UIColor(red: 0.953, green: 0.953, blue: 0.953, alpha: 1)
    static let disabledBorder = UIColor(red: 0.424, green: 0.463, blue: 0.514, alpha: 0.5)
    static let disabledTitle = UIColor(red: 0, green: 0, blue: 0, alpha: 0.4)
    static let disabledActivityIndicator = UIColor(red: 0.769, green: 0.769, blue: 0.769, alpha: 1)
}
