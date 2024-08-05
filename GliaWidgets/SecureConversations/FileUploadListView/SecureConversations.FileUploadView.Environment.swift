import Foundation

extension SecureConversations.FileUploadView {
    struct Environment {
        var uiScreen: UIKitBased.UIScreen
    }
}

extension SecureConversations.FileUploadView.Environment {
    static func create(with environment: SecureConversations.FileUploadListView.Environment) -> Self {
        .init(uiScreen: environment.uiScreen)
    }
}
