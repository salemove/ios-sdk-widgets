import Foundation
import SafariServices

extension SecureConversations {
    final class TranscriptCoordinator: FlowCoordinator {
        typealias DelegateEvent = Void

        var delegate: ((DelegateEvent) -> Void)?
        var environment: Environment
        let navigationPresenter: NavigationPresenter
        var presentedController: PresentedController?

        init(
            navigationPresenter: NavigationPresenter,
            environment: Environment
        ) {
            self.navigationPresenter = navigationPresenter
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
                    fetchChatHistory: environment.fetchChatHistory,
                    uiApplication: environment.uiApplication,
                    sendSecureMessage: environment.sendSecureMessage,
                    queueIds: environment.queueIds,
                    listQueues: environment.listQueues,
                    alertConfiguration: environment.alertConfiguration
                ),
                availability: .init(
                    environment: .init(
                        listQueues: environment.listQueues,
                        queueIds: environment.queueIds
                    )
                )
            )

            let controller = ChatViewController(
                viewModel: .transcript(model),
                viewFactory: environment.viewFactory
            )

            model.delegate = { [weak self, weak controller] event in
                switch event {
                case .showFile(let file):
                    self?.presentQuickLookController(with: file)
                case .openLink(let url):
                    self?.presentWebViewController(with: url)
                case let .showAlertAsView(conf, accessibilityIdentifier, dismissed):
                    controller?.presentAlertAsView(
                        with: conf,
                        accessibilityIdentifier: accessibilityIdentifier,
                        dismissed: dismissed
                    )
                }
            }

            return controller
        }

        private func presentQuickLookController(with file: LocalFile) {
            let viewModel = QuickLookViewModel(file: file)
            viewModel.delegate = { [weak self] event in
                switch event {
                case .finished:
                    self?.presentedController = nil
                }
            }
            let controller = QuickLookController(viewModel: viewModel)
            presentedController = .quickLook(controller)
            navigationPresenter.present(controller.viewController)
        }

        private func presentWebViewController(with url: URL) {
            let configuration = SFSafariViewController.Configuration()
            configuration.entersReaderIfAvailable = true
            let safariViewController = SFSafariViewController(url: url, configuration: configuration)
            safariViewController.view.accessibilityIdentifier = "safari_root_view"
            navigationPresenter.present(safariViewController)
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
        var uiApplication: UIKitBased.UIApplication
        var sendSecureMessage: CoreSdkClient.SendSecureMessage
        var queueIds: [String]
        var listQueues: CoreSdkClient.ListQueues
        var alertConfiguration: AlertConfiguration
    }
}

extension SecureConversations.TranscriptCoordinator {
    enum PresentedController {
        case quickLook(QuickLookController)
    }
}
