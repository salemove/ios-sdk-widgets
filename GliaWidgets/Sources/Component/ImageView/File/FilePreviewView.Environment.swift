import Foundation

extension FilePreviewView {
    struct Environment {
        var uiScreen: UIKitBased.UIScreen
    }
}

extension FilePreviewView.Environment {
    static func create(with environment: ChatFileDownloadContentView.Environment) -> Self {
        .init(uiScreen: environment.uiScreen)
    }
}
