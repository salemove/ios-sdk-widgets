import Foundation

extension SecureConversations.FilePreviewView {
    struct Environment {
        var uiScreen: UIKitBased.UIScreen
    }
}

extension SecureConversations.FilePreviewView.Environment {
    static func create(with environment: SecureConversations.FileUploadView.Environment) -> Self {
        .init(uiScreen: environment.uiScreen)
    }
}
