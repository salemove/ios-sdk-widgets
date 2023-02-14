import Foundation

extension SecureConversations {
    final class TranscriptCoordinator: FlowCoordinator {
        typealias DelegateEvent = Void

        var delegate: ((DelegateEvent) -> Void)?
        var environment: Environment

        init(environment: Environment) {
            self.environment = environment
        }

        func start() -> ChatViewController {
            let model = TranscriptModel(
                isCustomCardSupported: environment.viewFactory.messageRenderer != nil,
                environment: .init(
                    fetchFile: environment.fetchFile,
                    fileManager: environment.fileManager,
                    data: environment.data,
                    date: environment.date,
                    gcd: environment.gcd,
                    localFileThumbnailQueue: environment.localFileThumbnailQueue,
                    uiImage: environment.uiImage,
                    createFileDownload: environment.createFileDownload,
                    loadChatMessagesFromHistory: environment.loadChatMessagesFromHistory,
                    fetchChatHistory: environment.fetchChatHistory
                )
            )
            let controller = ChatViewController(
                viewModel: .transcript(model), viewFactory: environment.viewFactory
            )
            return controller
        }
    }
}

extension SecureConversations.TranscriptCoordinator {
    struct Environment {
        var viewFactory: ViewFactory
        var fetchFile: CoreSdkClient.FetchFile
        var fileManager: FoundationBased.FileManager
        var data: FoundationBased.Data
        var date: () -> Date
        var gcd: GCD
        var localFileThumbnailQueue: FoundationBased.OperationQueue
        var uiImage: UIKitBased.UIImage
        var createFileDownload: FileDownloader.CreateFileDownload
        var loadChatMessagesFromHistory: () -> Bool
        var fetchChatHistory: CoreSdkClient.FetchChatHistory
    }
}
