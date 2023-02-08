@testable import GliaWidgets

extension SecureConversations.FileUploadListViewModel.Environment {
    static let failing = SecureConversations.FileUploadListViewModel.Environment(
        uploader: .failing,
        style: .chat(.mock),
        uiApplication: .failing
    )
}
