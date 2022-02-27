import SafariServices
import UIKit

class ChatCoordinator: SubFlowCoordinator, FlowCoordinator {
    enum DelegateEvent {
        case back
        case engaged(operatorImageUrl: String?)
        case mediaUpgradeAccepted(
            offer: CoreSdkClient.MediaUpgradeOffer,
            answer: CoreSdkClient.AnswerWithSuccessBlock
        )
        case call
        case finished
    }

    var delegate: ((DelegateEvent) -> Void)?

    private let interactor: Interactor
    private let viewFactory: ViewFactory
    private let navigationPresenter: NavigationPresenter
    private let call: ObservableValue<Call?>
    private let showsCallBubble: Bool
    private let unreadMessages: ObservableValue<Int>
    private let isWindowVisible: ObservableValue<Bool>
    private let startAction: ChatViewModel.StartAction
    private let screenShareHandler: ScreenShareHandler
    private var mediaPickerController: MediaPickerController?
    private var filePickerController: FilePickerController?
    private var quickLookController: QuickLookController?
    private let environment: Environment

    init(
        interactor: Interactor,
        viewFactory: ViewFactory,
        navigationPresenter: NavigationPresenter,
        call: ObservableValue<Call?>,
        unreadMessages: ObservableValue<Int>,
        showsCallBubble: Bool,
        screenShareHandler: ScreenShareHandler,
        isWindowVisible: ObservableValue<Bool>,
        startAction: ChatViewModel.StartAction,
        environment: Environment
    ) {
        self.interactor = interactor
        self.viewFactory = viewFactory
        self.navigationPresenter = navigationPresenter
        self.call = call
        self.unreadMessages = unreadMessages
        self.showsCallBubble = showsCallBubble
        self.screenShareHandler = screenShareHandler
        self.isWindowVisible = isWindowVisible
        self.startAction = startAction
        self.environment = environment
    }

    func start() -> ChatViewController {
        let viewController = makeChatViewController()
        return viewController
    }

    private func makeChatViewController() -> ChatViewController {
        let viewModel = ChatViewModel(
            interactor: interactor,
            alertConfiguration: viewFactory.theme.alertConfiguration,
            screenShareHandler: screenShareHandler,
            call: call,
            unreadMessages: unreadMessages,
            showsCallBubble: showsCallBubble,
            isWindowVisible: isWindowVisible,
            startAction: startAction,
            environment: .init(
                chatStorage: environment.chatStorage,
                fetchFile: environment.fetchFile,
                sendSelectedOptionValue: environment.sendSelectedOptionValue,
                uploadFileToEngagement: environment.uploadFileToEngagement,
                fileManager: environment.fileManager,
                data: environment.data,
                date: environment.date,
                uuid: environment.uuid
            )
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
        return ChatViewController(viewModel: viewModel, viewFactory: viewFactory)
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
            self?.navigationPresenter.present(viewController)
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
        navigationPresenter.present(controller.viewController)
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
        navigationPresenter.present(controller.viewController)
    }

    private func presentWebViewController(with url: URL) {
        let configuration = SFSafariViewController.Configuration()
        configuration.entersReaderIfAvailable = true
        let safariViewController = SFSafariViewController(url: url, configuration: configuration)
        navigationPresenter.present(safariViewController)
    }
}

extension ChatCoordinator {
    struct Environment {
        var chatStorage: Glia.Environment.ChatStorage
        var fetchFile: CoreSdkClient.FetchFile
        var sendSelectedOptionValue: CoreSdkClient.SendSelectedOptionValue
        var uploadFileToEngagement: CoreSdkClient.UploadFileToEngagement
        var fileManager: FoundationBased.FileManager
        var data: FoundationBased.Data
        var date: () -> Date
        var uuid: () -> UUID
    }
}
