extension SecureConversations.FileUploadListViewModel {
    struct Environment {
        var uploader: FileUploader
        var style: SecureConversations.FileUploadListView.Style
        var uiApplication: UIKitBased.UIApplication
    }
}

#if DEBUG
extension SecureConversations.FileUploadListViewModel.Environment {
    static let mock = SecureConversations.FileUploadListViewModel.Environment(
        uploader: .mock(),
        style: .chat(.mock),
        uiApplication: .mock
    )
}
#endif
