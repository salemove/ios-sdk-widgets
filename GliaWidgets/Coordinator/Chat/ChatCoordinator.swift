import SalemoveSDK

class ChatCoordinator: SubFlowCoordinator, FlowCoordinator {
    enum DelegateEvent {
        case back
        case engaged(operatorImageUrl: String?)
        case mediaUpgradeAccepted(offer: MediaUpgradeOffer,
                                  answer: AnswerWithSuccessBlock)
        case call
        case finished
    }

    var delegate: ((DelegateEvent) -> Void)?

    private let interactor: Interactor
    private let viewFactory: ViewFactory
    private let navigationPresenter: NavigationPresenter
    private let call: ValueProvider<Call?>
    private let showsCallBubble: Bool
    private let unreadMessages: ValueProvider<Int>
    private let isWindowVisible: ValueProvider<Bool>
    private let startAction: ChatViewModel.StartAction

    init(interactor: Interactor,
         viewFactory: ViewFactory,
         navigationPresenter: NavigationPresenter,
         call: ValueProvider<Call?>,
         unreadMessages: ValueProvider<Int>,
         showsCallBubble: Bool,
         isWindowVisible: ValueProvider<Bool>,
         startAction: ChatViewModel.StartAction) {
        self.interactor = interactor
        self.viewFactory = viewFactory
        self.navigationPresenter = navigationPresenter
        self.call = call
        self.unreadMessages = unreadMessages
        self.showsCallBubble = showsCallBubble
        self.isWindowVisible = isWindowVisible
        self.startAction = startAction
    }

    func start() -> ChatViewController {
        let viewController = makeChatViewController()
        return viewController
    }

    private func makeChatViewController() -> ChatViewController {
        let viewModel = ChatViewModel(
            interactor: interactor,
            alertConfiguration: viewFactory.theme.alertConfiguration,
            call: call,
            unreadMessages: unreadMessages,
            showsCallBubble: showsCallBubble,
            isWindowVisible: isWindowVisible,
            startAction: startAction
        )
        viewModel.engagementDelegate = { [weak self] event in
            switch event {
            case .back:
                self?.delegate?(.back)
            case .engaged(operatorImageUrl: let url):
                self?.delegate?(.engaged(operatorImageUrl: url))
            case .finished:
                self?.delegate?(.finished)
            }
        }
        viewModel.delegate = { [weak self] event in
            switch event {
            case .mediaUpgradeAccepted(offer: let offer, answer: let answer):
                self?.delegate?(.mediaUpgradeAccepted(offer: offer, answer: answer))
            case .call:
                self?.delegate?(.call)
            }
        }
        return ChatViewController(viewModel: viewModel,
                                  viewFactory: viewFactory)
    }
}
