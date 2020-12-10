import UIKit

class ViewFactory {
    let theme: Theme

    init(with theme: Theme) {
        self.theme = theme
    }

    func makeChatView() -> ChatView {
        return ChatView(with: theme.chat)
    }

    func makeAlertView() -> AlertView {
        return AlertView(with: theme.alert)
    }

    func makeMinimizedOperatorImageView() -> UserImageView {
        return UserImageView(with: theme.minimizedOperator)
    }
}
