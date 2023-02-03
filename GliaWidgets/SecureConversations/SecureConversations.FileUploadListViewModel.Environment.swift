extension SecureConversations.FileUploadListViewModel {
    struct Environment {
        var uploader: FileUploader
        var style: FileUploadListStyle
        var uiApplication: UIKitBased.UIApplication
    }
}

#if DEBUG
extension SecureConversations.FileUploadListViewModel.Environment {
    static let mock = SecureConversations.FileUploadListViewModel.Environment(
        uploader: .mock(),
        style: .mock,
        uiApplication: .mock
    )
}
#endif
