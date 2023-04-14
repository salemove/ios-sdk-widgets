extension SecureConversations.FileUploadListViewModel {
    struct Environment {
        var uploader: FileUploader
        var style: SecureConversations.FileUploadListView.Style
        var uiApplication: UIKitBased.UIApplication
    }
}

#if DEBUG
extension SecureConversations.FileUploadListViewModel.Environment {
    // To avoid references being shared between tests
    // we make this mock a computed property, otherwise
    // changes from one test may leak to other tests.
    static var mock: SecureConversations.FileUploadListViewModel.Environment {
        .init(
            uploader: .mock(),
            style: .chat(.mock),
            uiApplication: .mock
        )
    }
}
#endif
