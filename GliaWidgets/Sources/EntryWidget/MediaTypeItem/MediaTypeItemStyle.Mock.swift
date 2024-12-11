#if DEBUG
import UIKit

extension EntryWidgetStyle.MediaTypeItemStyle {
    static func mock(
        chatTitle: String = "Chat",
        audioTitle: String = "Audio",
        videoTitle: String = "Video",
        secureMessagingTitle: String = "Secure messaging",
        titleFont: UIFont = .systemFont(ofSize: 16),
        titleColor: UIColor = .black,
        titleTextStyle: UIFont.TextStyle = .body,
        chatMessage: String = "Chat message",
        audioMessage: String = "Audio message",
        videoMessage: String = "Video message",
        secureMessagingMessage: String = "Secure messaging message",
        messageFont: UIFont = .systemFont(ofSize: 16),
        messageColor: UIColor = .black,
        unreadMessagesCounterFont: UIFont = .systemFont(ofSize: 16),
        unreadMessagesCounterColor: UIColor = .white,
        unreadMessagesCounterBackgroundColor: ColorType = .fill(color: .blue),
        messageTextStyle: UIFont.TextStyle = .footnote,
        iconColor: ColorType = .fill(color: .blue),
        backgroundColor: ColorType = .fill(color: .white),
        loading: LoadingStyle = .init(loadingTintColor: .fill(color: .gray)),
        accessibility: Accessibility = .unsupported
    ) -> Self {
        Self(
            chatTitle: chatTitle,
            audioTitle: audioTitle,
            videoTitle: videoTitle,
            secureMessagingTitle: secureMessagingTitle,
            titleFont: titleFont,
            titleColor: titleColor,
            titleTextStyle: titleTextStyle,
            chatMessage: chatMessage,
            audioMessage: audioMessage,
            videoMessage: videoMessage,
            secureMessagingMessage: secureMessagingMessage,
            messageFont: messageFont,
            messageColor: messageColor,
            unreadMessagesCounterFont: unreadMessagesCounterFont,
            unreadMessagesCounterColor: unreadMessagesCounterColor,
            unreadMessagesCounterBackgroundColor: unreadMessagesCounterBackgroundColor,
            messageTextStyle: messageTextStyle,
            iconColor: iconColor,
            backgroundColor: backgroundColor,
            loading: loading,
            accessibility: accessibility
        )
    }
}
#endif