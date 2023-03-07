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
    private let startWithSecureTranscriptFlow: Bool
    private weak var controller: ChatViewController?

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
        environment: Environment,
        startWithSecureTranscriptFlow: Bool
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
        self.startWithSecureTranscriptFlow = startWithSecureTranscriptFlow
    }

    func start() -> ChatViewController {
        let viewController = makeChatViewController()
        return viewController
    }

    private func makeChatViewController() -> ChatViewController {
        // We need to defer passing controller to transcript model,
        // because model will use it later, however controller
        // can not be created without model, that is why
        // we are to store it in coordinator and return in when needed.
        let model: SecureConversations.ChatWithTranscriptModel = startWithSecureTranscriptFlow
        ? .transcript(transcriptModel(with: { [weak self] in self?.controller }))
            : .chat(chatModel())
        let chatController = ChatViewController(viewModel: model, viewFactory: viewFactory)
        self.controller = chatController
        return chatController

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
        safariViewController.view.accessibilityIdentifier = "safari_root_view"
        navigationPresenter.present(safariViewController)
    }
}

// MARK: Chat model
extension ChatCoordinator {
    private func chatModel() -> ChatViewModel {
        let viewModel = ChatViewModel(
            interactor: interactor,
            alertConfiguration: viewFactory.theme.alertConfiguration,
            screenShareHandler: screenShareHandler,
            call: call,
            unreadMessages: unreadMessages,
            showsCallBubble: showsCallBubble,
            isCustomCardSupported: viewFactory.messageRenderer != nil,
            isWindowVisible: isWindowVisible,
            startAction: startAction,
            deliveredStatusText: viewFactory.theme.chat.visitorMessage.delivered,
            // We should not show enqueueing state in case of secure transcript flow.
            shouldSkipEnqueueingState: startWithSecureTranscriptFlow,
            environment: Self.enviromentForChatModel(environment: environment, viewFactory: viewFactory)
        )
        viewModel.isInteractableCard = viewFactory.messageRenderer?.isInteractable
        viewModel.shouldShowCard = viewFactory.messageRenderer?.shouldShowCard
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

        return viewModel
    }

    static func enviromentForChatModel(
        environment: Environment,
        viewFactory: ViewFactory
    ) -> ChatViewModel.Environment {
        ChatViewModel.Environment(
            fetchFile: environment.fetchFile,
            sendSelectedOptionValue: environment.sendSelectedOptionValue,
            uploadFileToEngagement: environment.uploadFileToEngagement,
            fileManager: environment.fileManager,
            data: environment.data,
            date: environment.date,
            gcd: environment.gcd,
            localFileThumbnailQueue: environment.localFileThumbnailQueue,
            uiImage: environment.uiImage,
            createFileDownload: environment.createFileDownload,
            loadChatMessagesFromHistory: environment.fromHistory,
            fetchSiteConfigurations: environment.fetchSiteConfigurations,
            getCurrentEngagement: environment.getCurrentEngagement,
            timerProviding: .live,
            uuid: environment.uuid,
            uiApplication: environment.uiApplication,
            fetchChatHistory: environment.fetchChatHistory,
            fileUploadListStyle: viewFactory.theme.chatStyle.messageEntry.uploadList,
            createFileUploadListModel: environment.createFileUploadListModel
        )
    }
}

// MARK: Transcript model
extension ChatCoordinator {
    private func transcriptModel(with controller: @escaping () -> ChatViewController?) -> SecureConversations.TranscriptModel {
        let viewModel = SecureConversations.TranscriptModel(
            isCustomCardSupported: viewFactory.messageRenderer != nil,
            environment: Self.environmentForTranscriptModel(
                environment: environment,
                viewFactory: viewFactory
            ),
            availability: .init(
                environment: .init(
                    listQueues: environment.listQueues,
                    queueIds: environment.queueIds
                )
            ),
            deliveredStatusText: viewFactory.theme.chat.visitorMessage.delivered
        )

        viewModel.delegate = { [weak self] event in
            switch event {
            case .showFile(let file):
                self?.presentQuickLookController(with: file)
            case .openLink(let url):
                self?.presentWebViewController(with: url)
            case let .showAlertAsView(conf, accessibilityIdentifier, dismissed):
                controller()?.presentAlertAsView(
                    with: conf,
                    accessibilityIdentifier: accessibilityIdentifier,
                    dismissed: dismissed
                )
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
            case let .awaitUpgradeToChatEngagement(transcriptModel):
                guard let self, let controller = controller() else {
                    return
                }
                let chatModel = self.chatModel()
                controller.swapAndBindViewModel(.chat(chatModel))
                chatModel.migrate(from: transcriptModel)
            }
        }

        return viewModel
    }

    static func environmentForTranscriptModel(
        environment: Environment,
        viewFactory: ViewFactory
    ) -> SecureConversations.TranscriptModel.Environment {
        SecureConversations.TranscriptModel.Environment(
           fetchFile: environment.fetchFile,
           fileManager: environment.fileManager,
           data: environment.data,
           date: environment.date,
           gcd: environment.gcd,
           localFileThumbnailQueue: environment.localFileThumbnailQueue,
           uiImage: environment.uiImage,
           createFileDownload: environment.createFileDownload,
           loadChatMessagesFromHistory: environment.fromHistory,
           fetchChatHistory: environment.fetchChatHistory,
           uiApplication: environment.uiApplication,
           sendSecureMessage: environment.sendSecureMessage,
           queueIds: environment.queueIds,
           listQueues: environment.listQueues,
           alertConfiguration: viewFactory.theme.alertConfiguration,
           createFileUploadListModel: environment.createFileUploadListModel,
           uuid: environment.uuid,
           secureUploadFile: environment.secureUploadFile,
           fileUploadListStyle: viewFactory.theme.chatStyle.messageEntry.uploadList,
           fetchSiteConfigurations: environment.fetchSiteConfigurations
       )
    }
}
