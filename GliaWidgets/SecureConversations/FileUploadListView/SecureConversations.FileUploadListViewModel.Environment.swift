@_spi(GliaWidgets) import GliaCoreSDK

extension SecureConversations.FileUploadListViewModel {
    struct Environment {
        var uploader: FileUploader
        var style: SecureConversations.FileUploadListView.Style
        var scrollingBehaviour: ScrollingBehaviour
        @Dependency(\.widgets.openTelemetry) var openTelemetry: OpenTelemetry
    }
}

extension SecureConversations.FileUploadListViewModel.Environment {
    enum ScrollingBehaviour {
        case scrolling(UIKitBased.UIApplication)
        case nonScrolling

        var isScrollingEnabled: Bool {
            switch self {
            case .scrolling:
                return true
            case .nonScrolling:
                return false
            }
        }
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
            scrollingBehaviour: .scrolling(.mock)
        )
    }
}
#endif
