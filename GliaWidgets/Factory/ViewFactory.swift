final class ViewFactory {
    private let theme: Theme

    init(with theme: Theme) {
        self.theme = theme
    }

    func makeChatView() -> ChatView {
        return ChatView(with: theme.chatStyle)
    }
}
