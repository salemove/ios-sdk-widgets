import SalemoveSDK
import SafariServices

final class ChatCoordinator: UIViewControllerCoordinator {
    enum DelegateEvent {
        case back
        case engaged(operatorImageUrl: String?)
        case finished
        case callBubbleTapped
        case alert(Alert)
    }

    var delegate: ((DelegateEvent) -> Void)?

    private let interactor: Interactor
    private let viewFactory: ViewFactory
    private let showsCallBubble: Bool
    private let startAction: ChatViewModel.StartAction
    private let screenShareHandler: ScreenShareHandler
    private let messageDispatcher: MessageDispatcher

    private weak var presenter: UIViewController?

    private var mediaPickerController: MediaPickerController?
    private var filePickerController: FilePickerController?
    private var quickLookController: QuickLookController?

    init(
        interactor: Interactor,
        viewFactory: ViewFactory,
        showsCallBubble: Bool,
        screenShareHandler: ScreenShareHandler,
        messageDispatcher: MessageDispatcher,
        startAction: ChatViewModel.StartAction
    ) {
        self.interactor = interactor
        self.viewFactory = viewFactory
        self.showsCallBubble = showsCallBubble
        self.screenShareHandler = screenShareHandler
        self.messageDispatcher = messageDispatcher
        self.startAction = startAction
    }

    override func start() -> ChatViewController {
        let viewModel = ChatViewModel(
            interactor: interactor,
            alertConfiguration: viewFactory.theme.alertConfiguration,
            screenShareHandler: screenShareHandler,
            messageDispatcher: messageDispatcher,
            showsCallBubble: showsCallBubble,
            startAction: startAction
        )

        viewModel.engagementDelegate = { [weak self] event in
            switch event {
            case .back:
                self?.delegate?(.back)

            case .engaged(let url):
                self?.delegate?(.engaged(operatorImageUrl: url))

            case .finished:
                self?.delegate?(.finished)

            case .alert(let alert):
                self?.delegate?(.alert(alert))
            }
        }

        viewModel.delegate = { [weak self] event in
            switch event {
            case .pickMedia(let pickerEvent):
                self?.presentMediaPickerController(
                    with: pickerEvent,
                    mediaSource: .library,
                    mediaTypes: [.image, .movie]
                )

            case .takeMedia(let pickerEvent):
                self?.presentMediaPickerController(
                    with: pickerEvent,
                    mediaSource: .camera,
                    mediaTypes: [.image, .movie]
                )

            case .pickFile(let pickerEvent):
                self?.presentFilePickerController(with: pickerEvent)

            case .showFile(let file):
                self?.presentQuickLookController(with: file)

            case .openLink(let url):
                self?.presentWebViewController(with: url)

            case .callBubbleTapped:
                self?.delegate?(.callBubbleTapped)
            }
        }

        let viewController = ChatViewController(
            viewModel: viewModel,
            viewFactory: viewFactory
        )

        self.presenter = viewController

        return viewController
    }

    private func presentMediaPickerController(
        with pickerEvent: CurrentValueSubject<MediaPickerEvent>,
        mediaSource: MediaPickerViewModel.MediaSource,
        mediaTypes: [MediaPickerViewModel.MediaType]
    ) {
        let viewModel = MediaPickerViewModel(
            pickerEvent: pickerEvent,
            mediaSource: mediaSource,
            mediaTypes: mediaTypes
        )
        let controller = MediaPickerController(viewModel: viewModel)

        viewModel.delegate = { [weak self] event in
            switch event {
            case .finished:
                self?.mediaPickerController = nil
            }
        }

        mediaPickerController = controller
        controller.viewController { [weak self] viewController in
            self?.presenter?.present(viewController, animated: true)
        }
    }

    private func presentFilePickerController(
        with pickerEvent: CurrentValueSubject<FilePickerEvent>
    ) {
        let viewModel = FilePickerViewModel(pickerEvent: pickerEvent)
        let controller = FilePickerController(viewModel: viewModel)

        viewModel.delegate = { [weak self] event in
            switch event {
            case .finished:
                self?.filePickerController = nil
            }
        }

        filePickerController = controller
        presenter?.present(controller.viewController, animated: true)
    }

    private func presentQuickLookController(with file: LocalFile) {
        let viewModel = QuickLookViewModel(file: file)
        let controller = QuickLookController(viewModel: viewModel)

        viewModel.delegate = { [weak self] event in
            switch event {
            case .finished:
                self?.quickLookController = nil
            }
        }

        quickLookController = controller
        presenter?.present(controller.viewController, animated: true)
    }

    private func presentWebViewController(with url: URL) {
        let configuration = SFSafariViewController.Configuration()
        configuration.entersReaderIfAvailable = true
        let safariViewController = SFSafariViewController(url: url, configuration: configuration)
        presenter?.present(safariViewController, animated: true)
    }
}
