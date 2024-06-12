import Foundation

extension ChatMessageView {
    struct Environment {
        var uiScreen: UIKitBased.UIScreen
    }
}

extension ChatMessageView.Environment {
    static func create(with environment: ChatView.Environment) -> Self {
        .init(uiScreen: environment.uiScreen)
    }
}
