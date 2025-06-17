import SafariServices
import UIKit

class ChatCoordinator: SubFlowCoordinator, FlowCoordinator {
    enum DelegateEvent {
        case back
        case openLink(WebViewController.Link)
        case engaged(operatorImageUrl: String?)
        case secureTranscriptUpgradedToLiveChat(ChatViewController)
        case mediaUpgradeAccepted(
            offer: CoreSdkClient.MediaUpgradeOffer,
            answer: CoreSdkClient.AnswerWithSuccessBlock
        )
        case call
        case finished
        case minimize
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
    private(set) var mediaPickerController: MediaPickerController?
    private(set) var filePickerController: FilePickerController?
    private(set) var quickLookController: QuickLookController?
    private let environment: Environment
    private let startWithSecureTranscriptFlow: Bool

    /// Used to determine if handling Transferred SC should be skipped.
    /// - has `true` in cases when visitor left conversation using either Leave Current Conversation dialog
    /// or Chat top banner and get navigated to Live Chat.
    /// - has `false` in case when Chat screen was opened directly, for example
    /// when Chat engagement initiated and there is `hasPendingInteraction` returns `false`.
    private let skipTransferredSCHandling: Bool
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
        startWithSecureTranscriptFlow: Bool,
        skipTransferredSCHandling: Bool
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
        self.skipTransferredSCHandling = skipTransferredSCHandling
    }

    func start() -> ChatViewController {
        start(replaceExistingEnqueueing: false)
    }

    func start(replaceExistingEnqueueing: Bool) -> ChatViewController {
        let viewController = makeChatViewController(
            replaceExistingEnqueueing: replaceExistingEnqueueing
        )
        return viewController
    }

    private func makeChatViewController(replaceExistingEnqueueing: Bool) -> ChatViewController {
        // We need to defer passing controller to transcript model,
        // because model will use it later, however controller
        // can not be created without model, that is why
        // we are to store it in coordinator and return in when needed.
        let model: SecureConversations.ChatWithTranscriptModel

        let start: () -> Void

        defer {
            start()
        }

        if startWithSecureTranscriptFlow {
            let transcriptModel = transcriptModel(with: { [weak self] in self?.controller })
            model = .transcript(transcriptModel)
            // For initial SC flow (when it is started), start method was called
            // from view did load initiating socket events observation and loading
            // chat transcript. Now, because of migration back from chat to SC is
            // possible we need to call `start` here.
            start = { transcriptModel.start(isTranscriptFetchNeeded: true) }
        } else {
            model = .chat(chatModel(replaceExistingEnqueueing: replaceExistingEnqueueing))
            start = {}
        }

        environment.log.prefixed(Self.self).info("Create Chat screen")

        let chatController = ChatViewController(
            viewModel: model,
            environment: .create(
                with: environment,
                viewFactory: viewFactory
            )
        )
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

        let controller = FilePickerController(
            viewModel: viewModel,
            environment: .create(with: environment)
        )
        filePickerController = controller
        navigationPresenter.present(controller.viewController)
    }

    private func presentQuickLookController(with file: LocalFile) {
        let viewModel = QuickLookViewModel(file: file, environment: .create(with: environment))
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
}

// MARK: Chat model
extension ChatCoordinator {
    private func chatModel(replaceExistingEnqueueing: Bool) -> ChatViewModel {
        let isTransferredSecureConversation = !skipTransferredSCHandling &&
        environment.getCurrentEngagement()?.isTransferredSecureConversation == true

        let chatType = Self.chatType(
            isTransferredToSecureConversations: isTransferredSecureConversation,
            startWithSecureTranscriptFlow: startWithSecureTranscriptFlow,
            isAuthenticated: environment.isAuthenticated()
        )
        let viewModel = ChatViewModel(
            interactor: interactor,
            screenShareHandler: screenShareHandler,
            call: call,
            unreadMessages: unreadMessages,
            showsCallBubble: showsCallBubble,
            isCustomCardSupported: viewFactory.messageRenderer != nil,
            isWindowVisible: isWindowVisible,
            startAction: startAction,
            deliveredStatusText: viewFactory.theme.chat.visitorMessageStyle.delivered,
            failedToDeliverStatusText: viewFactory.theme.chat.visitorMessageStyle.failedToDeliver,
            chatType: chatType,
            replaceExistingEnqueueing: replaceExistingEnqueueing,
            environment: .create(
                with: environment,
                viewFactory: viewFactory
            ),
            maximumUploads: environment.maximumUploads
        )
        viewModel.isInteractableCard = viewFactory.messageRenderer?.isInteractable
        viewModel.shouldShowCard = viewFactory.messageRenderer?.shouldShowCard
        viewModel.engagementDelegate = { [weak self] event in
            self?.handleEngagementDelegateEvent(event)
        }
        viewModel.delegate = { [weak self] event in
            self?.handleDelegateEvent(event: event)
        }

        return viewModel
    }

    private func handleDelegateEvent(event: ChatViewModel.DelegateEvent) {
        switch event {
        case .pickMedia(let pickerEvent):
            presentMediaPickerController(
                with: pickerEvent,
                mediaSource: .library,
                mediaTypes: [.image, .movie]
            )
        case .takeMedia(let pickerEvent):
            presentMediaPickerController(
                with: pickerEvent,
                mediaSource: .camera,
                mediaTypes: [.image, .movie]
            )
        case .pickFile(let pickerEvent):
            presentFilePickerController(with: pickerEvent)
        case .mediaUpgradeAccepted(let offer, let answer):
            delegate?(.mediaUpgradeAccepted(offer: offer, answer: answer))
        case .secureTranscriptUpgradedToLiveChat(let chatViewController):
            delegate?(.secureTranscriptUpgradedToLiveChat(chatViewController))
        case .showFile(let file):
            presentQuickLookController(with: file)
        case .call:
            delegate?(.call)
        case .minimize:
            delegate?(.minimize)
        case let .liveChatEngagementUpgradedToSecureMessaging(chatModel):
            let transcriptModel = self.transcriptModel(with: { [weak controller] in controller })
            controller?.swapAndBindViewModel(.transcript(transcriptModel))
            transcriptModel.migrate(from: chatModel)
        }
    }

    func handleEngagementDelegateEvent(_ event: EngagementViewModel.DelegateEvent) {
        switch event {
        case .back:
            self.delegate?(.back)
        case let .openLink(link):
            self.delegate?(.openLink(link))
        case .engaged(let url):
            self.delegate?(.engaged(operatorImageUrl: url))
        case .finished:
            self.delegate?(.finished)
        }
    }
}

// MARK: Transcript model
extension ChatCoordinator {
    private func transcriptModel(with controller: @escaping () -> ChatViewController?) -> SecureConversations.TranscriptModel {
        let viewModel = SecureConversations.TranscriptModel(
            isCustomCardSupported: viewFactory.messageRenderer != nil,
            environment: .create(
                with: environment,
                viewFactory: viewFactory
            ),
            availability: .init(environment: .create(with: environment)),
            deliveredStatusText: viewFactory.theme.chat.visitorMessageStyle.delivered,
            failedToDeliverStatusText: viewFactory.theme.chat.visitorMessageStyle.failedToDeliver,
            unreadMessages: unreadMessages,
            interactor: interactor
        )

        viewModel.shouldShowCard = viewFactory.messageRenderer?.shouldShowCard
        viewModel.isInteractableCard = viewFactory.messageRenderer?.isInteractable
        viewModel.engagementDelegate = { [weak self] event in
            switch event {
            case .finished:
                self?.delegate?(.finished)
            default: break
            }
        }

        configureDelegate(for: viewModel, controller: controller)

        return viewModel
    }

    private func configureDelegate(
        for viewModel: SecureConversations.TranscriptModel,
        controller: @escaping () -> ChatViewController?
    ) {
        viewModel.delegate = { [weak self] event in
            switch event {
            case .showFile(let file):
                self?.presentQuickLookController(with: file)
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
            case let .upgradeToChatEngagement(transcriptModel):
                guard let self, let controller = controller() else {
                    return
                }
                let chatModel = self.chatModel(replaceExistingEnqueueing: false)
                controller.swapAndBindViewModel(.chat(chatModel))
                chatModel.migrate(from: transcriptModel)
                self.delegate?(.secureTranscriptUpgradedToLiveChat(controller))
            case .minimize:
                self?.delegate?(.minimize)
            }
        }
    }
}

// MARK: - Static methods

extension ChatCoordinator {
    static func chatType(
        isTransferredToSecureConversations: Bool,
        startWithSecureTranscriptFlow: Bool,
        isAuthenticated: Bool
    ) -> ChatViewModel.ChatType {
        if isTransferredToSecureConversations {
            return .secureTranscript(upgradedFromChat: true)
        } else if startWithSecureTranscriptFlow {
            return .secureTranscript(upgradedFromChat: false)
        } else if isAuthenticated {
            return .authenticated
        } else {
            return .nonAuthenticated
        }
    }
}
