import Foundation

extension SystemMessageView {
    struct Environment {
        var uiScreen: UIKitBased.UIScreen
    }
}

extension SystemMessageView.Environment {
    static func create(with environment: ChatView.Environment) -> Self {
        .init(uiScreen: environment.uiScreen)
    }
}
