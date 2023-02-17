import Foundation
import UIKit

extension SecureConversations {
    final class Coordinator: SubFlowCoordinator, FlowCoordinator {
        var delegate: ((DelegateEvent) -> Void)?
        private let viewFactory: ViewFactory
        private let navigationPresenter: NavigationPresenter
        private let environment: Environment
        private var viewModel: SecureConversations.WelcomeViewModel?
        private var selectedPickerController: SelectedPickerController?

        init(
            viewFactory: ViewFactory,
            navigationPresenter: NavigationPresenter,
            environment: Environment
        ) {
            self.viewFactory = viewFactory
            self.navigationPresenter = navigationPresenter
            self.environment = environment
        }

        func start() -> UIViewController {
            let viewController = makeSecureConversationsWelcomeViewController()

            return viewController
        }

        private func makeWelcomeViewModel() -> SecureConversations.WelcomeViewModel {
            SecureConversations.WelcomeViewModel(
                environment: .init(
                    welcomeStyle: viewFactory.theme.secureConversationsWelcomeStyle,
                    queueIds: environment.queueIds,
                    listQueues: environment.listQueues,
                    sendSecureMessage: environment.sendSecureMessage,
                    alertConfiguration: viewFactory.theme.alertConfiguration,
                    fileUploader: environment.createFileUploader(
                        SecureConversations.WelcomeViewModel.maximumUploads,
                        .init(
                            uploadFile: .toConversation(environment.uploadSecureFile),
                            fileManager: environment.fileManager,
                            data: environment.data,
                            date: environment.date,
                            gcd: environment.gcd,
                            localFileThumbnailQueue: environment.localFileThumbnailQueue,
                            uiImage: environment.uiImage,
                            uuid: environment.uuid
                        )
                    ),
                    uiApplication: environment.uiApplication,
                    createFileUploadListModel: environment.createFileUploadListModel
                )
            )
        }

        private func makeSecureConversationsWelcomeViewController() -> SecureConversations.WelcomeViewController {
            let viewModel = makeWelcomeViewModel()

            let controller = SecureConversations.WelcomeViewController(
                viewFactory: viewFactory,
                props: viewModel.props()
            )

            viewModel.delegate = { [weak self, weak controller] event in
                self?.bindDelegate(to: event, controller: controller)
            }

            // Store view model, so that it would not be deallocated.
            self.viewModel = viewModel

            return controller
        }

        private func bindDelegate(
            to event: WelcomeViewModel.DelegateEvent,
            controller: WelcomeViewController?
        ) {
            let style = viewFactory.theme.secureConversationsWelcomeStyle
            switch event {
            case .backTapped:
                delegate?(.backTapped)
            case .closeTapped:
                delegate?(.closeTapped)
            // Bind changes in view model to view controller.
            case let .renderProps(props):
                controller?.props = props
            case .confirmationScreenRequested:
                presentSecureConversationsConfirmationViewController()
            case let .mediaPickerRequested(originView, callback):
                controller?.presentPopover(
                    with: style.pickMediaStyle,
                    from: originView,
                    // Designs use 'up' arrow, but currently
                    // it seems like there is a bug in
                    // AttachmentSourceListView, that makes
                    // it render incorrectly with 'up' arrow.
                    // That is why using 'down' arrow for now.
                    arrowDirections: .down,
                    itemSelected: { [weak controller] kind in
                        controller?.dismiss(animated: true)
                        callback(kind)
                    }
                )
            case let .pickMedia(callback):
                presentMediaPickerController(
                    with: callback,
                    mediaSource: .library,
                    mediaTypes: [.image, .movie]
                )
            case let .takeMedia(callback):
                presentMediaPickerController(
                    with: callback,
                    mediaSource: .camera,
                    mediaTypes: [.image, .movie]
                )
            case let .pickFile(callback):
                presentFilePickerController(with: callback)
            case let .showAlert(conf, accessibilityIdentifier, dismissed):
                controller?.presentAlert(
                    with: conf,
                    accessibilityIdentifier: accessibilityIdentifier,
                    dismissed: dismissed
                )
            case let .showAlertAsView(conf, accessibilityIdentifier, dismissed):
                controller?.presentAlertAsView(
                    with: conf,
                    accessibilityIdentifier: accessibilityIdentifier,
                    dismissed: dismissed
                )
            case let .showSettingsAlert(conf, cancelled):
                controller?.presentSettingsAlert(
                    with: conf, cancelled: cancelled
                )
            case .transcriptRequested:
                navigateToTranscript()
            }
        }

        func presentSecureConversationsConfirmationViewController() {
            let viewModel = SecureConversations.ConfirmationViewModel(
                environment: .init(
                    confirmationStyle: viewFactory.theme.secureConversationsConfirmationStyle
                )
            )

            let controller = SecureConversations.ConfirmationViewController(
                viewModel: viewModel,
                viewFactory: viewFactory,
                props: viewModel.props()
            )

            viewModel.delegate = { [weak self, weak controller] event in
                switch event {
                case .backTapped:
                    self?.delegate?(.backTapped)
                case .closeTapped:
                    self?.delegate?(.closeTapped)
                // Bind changes in view model to view controller.
                case let .renderProps(props):
                    controller?.props = props
                }
            }

            self.navigationPresenter.push(
                controller,
                animated: true,
                replacingLast: true
            )
        }

        private func presentMediaPickerController(
            with pickerEvent: Command<MediaPickerEvent>,
            mediaSource: MediaPickerViewModel.MediaSource,
            mediaTypes: [MediaPickerViewModel.MediaType]
        ) {
            let observable = ObservableValue<MediaPickerEvent>(with: .none)
            observable.addObserver(self, update: { newValue, _ in pickerEvent(newValue) })
            let viewModel = MediaPickerViewModel(
                pickerEvent: observable,
                mediaSource: mediaSource,
                mediaTypes: mediaTypes
            )

            viewModel.delegate = { [weak self] event in
                switch event {
                case .finished:
                    self?.selectedPickerController = nil
                }
            }

            let controller = MediaPickerController(viewModel: viewModel)
            controller.viewController { [weak self] viewController in
                self?.navigationPresenter.present(viewController)
            }
            // Keep strong reference, otherwise
            // `controller` will be deallocted, resulting in
            // event not being sent.
            self.selectedPickerController = .mediaPickerController(controller)
        }

        private func presentFilePickerController(with pickerEvent: Command<FilePickerEvent>) {
            let observable = ObservableValue<FilePickerEvent>(with: .none)
            observable.addObserver(self, update: { event, _ in pickerEvent(event) })
            let viewModel = FilePickerViewModel(pickerEvent: observable)
            viewModel.delegate = { [weak self] event in
                switch event {
                case .finished:
                    self?.selectedPickerController = nil
                }
            }
            let controller = FilePickerController(viewModel: viewModel)
            // Keep strong reference, otherwise
            // `controller` will be deallocted, resulting in
            // event not being sent.
            self.selectedPickerController = .filePickerController(controller)

            navigationPresenter.present(controller.viewController)
        }

        private func navigateToTranscript() {
            let transcriptCoordinator = TranscriptCoordinator(
                navigationPresenter: navigationPresenter,
                environment: .init(
                    viewFactory: environment.viewFactory,
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
                    uiApplication: environment.uiApplication
                )
            )
            pushCoordinator(transcriptCoordinator)
            navigationPresenter.push(
                transcriptCoordinator.start(),
                replacingLast: true
            )
        }
    }
}

extension SecureConversations.Coordinator {
    struct Environment {
        var queueIds: [String]
        var listQueues: CoreSdkClient.ListQueues
        var sendSecureMessage: CoreSdkClient.SendSecureMessage
        var createFileUploader: FileUploader.Create
        var uploadSecureFile: CoreSdkClient.SecureConversationsUploadFile
        var fileManager: FoundationBased.FileManager
        var data: FoundationBased.Data
        var date: () -> Date
        var gcd: GCD
        var localFileThumbnailQueue: FoundationBased.OperationQueue
        var uiImage: UIKitBased.UIImage
        var uuid: () -> UUID
        var uiApplication: UIKitBased.UIApplication
        var createFileUploadListModel: SecureConversations.FileUploadListViewModel.Create
        var viewFactory: ViewFactory
        var fetchFile: CoreSdkClient.FetchFile
        var createFileDownload: FileDownloader.CreateFileDownload
        var loadChatMessagesFromHistory: () -> Bool
        var fetchChatHistory: CoreSdkClient.FetchChatHistory
    }

    enum DelegateEvent {
        case backTapped
        case closeTapped
    }
}

extension SecureConversations.Coordinator {
    enum SelectedPickerController {
        case filePickerController(FilePickerController)
        case mediaPickerController(MediaPickerController)
    }
}
