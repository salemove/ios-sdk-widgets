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

    static func create(with environment: GvaResponseTextView.Environment) -> Self {
        .init(uiScreen: environment.uiScreen)
    }

    static func create(with environment: VisitorChatMessageView.Environment) -> Self {
        .init(uiScreen: environment.uiScreen)
    }

    static func create(with environment: OperatorChatMessageView.Environment) -> Self {
        .init(uiScreen: environment.uiScreen)
    }

    static func create(with environment: SystemMessageView.Environment) -> Self {
        .init(uiScreen: environment.uiScreen)
    }
}
