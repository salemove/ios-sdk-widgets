import Foundation

extension ChatFileDownloadContentView {
    struct Environment {
        var uiScreen: UIKitBased.UIScreen
    }
}

extension ChatFileDownloadContentView.Environment {
    static func create(with environment: ChatMessageView.Environment) -> Self {
        .init(uiScreen: environment.uiScreen)
    }
}
