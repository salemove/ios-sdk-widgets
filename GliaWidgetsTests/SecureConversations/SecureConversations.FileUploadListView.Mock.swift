import Foundation
@testable import GliaWidgets

extension SecureConversations.FileUploadListView.Props {
    static let mock = SecureConversations.FileUploadListView.Props(
        maxUnscrollableViews: 0,
        style: SecureConversations.FileUploadListView.Style.chat(
            FileUploadListStyle(item: FileUploadStyle.initial)
        ),
        uploads: .init([])
    )
}
