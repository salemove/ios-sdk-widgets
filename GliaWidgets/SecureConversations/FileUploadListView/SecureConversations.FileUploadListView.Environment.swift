import Foundation

extension SecureConversations.FileUploadListView {
    struct Environment {
        var uiScreen: UIKitBased.UIScreen
    }
}

extension SecureConversations.FileUploadListView.Environment {
    static func create(with environment: SecureConversations.WelcomeView.Environemnt) -> Self {
        .init(uiScreen: environment.uiScreen)
    }

    static func create(with environment: ChatMessageEntryView.Environment) -> Self {
        .init(uiScreen: environment.uiScreen)
    }
}
