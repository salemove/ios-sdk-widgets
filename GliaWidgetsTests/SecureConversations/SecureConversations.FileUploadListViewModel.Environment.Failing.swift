@testable import GliaWidgets

extension SecureConversations.FileUploadListViewModel.Environment {
    static let failing = SecureConversations.FileUploadListViewModel.Environment(
        uploader: .failing,
        style: .chat(.mock),
        scrollingBehaviour: .scrolling(.failing)
    )

    static func failing(
        uploader: FileUploader = .failing,
        style: SecureConversations.FileUploadListView.Style = .chat(.mock),
        scrollingBehaviour: ScrollingBehaviour = .scrolling(.failing)
    ) -> SecureConversations.FileUploadListViewModel.Environment{
        .init(
            uploader: uploader,
            style: style,
            scrollingBehaviour: scrollingBehaviour
        )
    }
}
