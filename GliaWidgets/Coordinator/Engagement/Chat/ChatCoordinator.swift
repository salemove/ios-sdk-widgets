import SalemoveSDK
import SafariServices

final class ChatCoordinator: UIViewControllerCoordinator {
    enum DelegateEvent {
        case back
        case engaged(operatorImageUrl: String?)
        case mediaUpgradeAccepted(
            offer: MediaUpgradeOffer,
            answer: AnswerWithSuccessBlock
        )
        case call
        case finished

        case endScreenShareAlert(confirmed: (() -> Void))
        case startScreenShareAlert(operatorName: String, answer: AnswerBlock)
        case leaveQueueAlert(confirmed: (() -> Void))
        case endEngagementAlert(confirmed: (() -> Void))
        case mediaUpgradeAlert(offer: MediaUpgradeOffer,
                               answer: AnswerWithSuccessBlock)
    }

    var delegate: ((DelegateEvent) -> Void)?

    private let interactor: Interactor
    private let viewFactory: ViewFactory
    private let showsCallBubble: Bool
    private let startAction: ChatViewModel.StartAction
    private let screenShareHandler: ScreenShareHandler
    private let unreadMessagesHandler: UnreadMessagesHandler

    private weak var presenter: UIViewController?

    // TODO: remove
    private var mediaPickerController: MediaPickerController?
    private var filePickerController: FilePickerController?
    private var quickLookController: QuickLookController?

    init(
        interactor: Interactor,
        viewFactory: ViewFactory,
        showsCallBubble: Bool,
        screenShareHandler: ScreenShareHandler,
        unreadMessagesHandler: UnreadMessagesHandler,
        startAction: ChatViewModel.StartAction
    ) {
        self.interactor = interactor
        self.viewFactory = viewFactory
        self.showsCallBubble = showsCallBubble
        self.screenShareHandler = screenShareHandler
        self.unreadMessagesHandler = unreadMessagesHandler
        self.startAction = startAction
    }

    override func start() -> ChatViewController {
        let viewModel = ChatViewModel(
            interactor: interactor,
            alertConfiguration: viewFactory.theme.alertConfiguration,
            screenShareHandler: screenShareHandler,
            unreadMessagesHandler: unreadMessagesHandler,
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
            }
        }

        viewModel.alertDelegate = { [weak self] in
            switch $0 {
            case .leaveQueueAlert(let confirmationBlock):
                self?.delegate?(.leaveQueueAlert(confirmed: confirmationBlock))

            case .endEngagementAlert(let confirmationBlock):
                self?.delegate?(.endEngagementAlert(confirmed: confirmationBlock))

            case .startScreenShareAlert(let operatorName, let answer):
                self?.delegate?(.startScreenShareAlert(operatorName: operatorName, answer: answer))

            case .endScreenShareAlert(let confirmationBlock):
                self?.delegate?(.endScreenShareAlert(confirmed: confirmationBlock))

            case .mediaUpgradeAlert(let offer, let answerBlock):
                self?.delegate?(.mediaUpgradeAlert(offer: offer, answer: answerBlock))
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
            case .mediaUpgradeAccepted(let offer, let answer):
                self?.delegate?(.mediaUpgradeAccepted(offer: offer, answer: answer))
            case .showFile(let file):
                self?.presentQuickLookController(with: file)
            case .call:
                self?.delegate?(.call)
            case .openLink(let url):
                self?.presentWebViewController(with: url)
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
        with pickerEvent: ObservableValue<MediaPickerEvent>,
        mediaSource: MediaPickerViewModel.MediaSource,
        mediaTypes: [MediaPickerViewModel.MediaType]
    ) {
        let viewModel = MediaPickerViewModel(
            pickerEvent: pickerEvent,
            mediaSource: mediaSource,
            mediaTypes: mediaTypes
        )
        viewModel.delegate = { [weak self] event in
            switch event {
            case .finished:
                self?.mediaPickerController = nil
            }
        }

        let controller = MediaPickerController(viewModel: viewModel)
        mediaPickerController = controller
        controller.viewController { [weak self] viewController in
            self?.presenter?.present(viewController, animated: true)
        }
    }

    private func presentFilePickerController(with pickerEvent: ObservableValue<FilePickerEvent>) {
        let viewModel = FilePickerViewModel(pickerEvent: pickerEvent)
        viewModel.delegate = { [weak self] event in
            switch event {
            case .finished:
                self?.filePickerController = nil
            }
        }

        let controller = FilePickerController(viewModel: viewModel)
        filePickerController = controller
        presenter?.present(controller.viewController, animated: true)
    }

    private func presentQuickLookController(with file: LocalFile) {
        let viewModel = QuickLookViewModel(file: file)
        viewModel.delegate = { [weak self] event in
            switch event {
            case .finished:
                self?.quickLookController = nil
            }
        }
        let controller = QuickLookController(viewModel: viewModel)
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
