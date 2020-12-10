class ChatCoordinator: SubFlowCoordinator, FlowCoordinator {
    enum DelegateEvent {
        case back
        case finished
    }

    var delegate: ((DelegateEvent) -> Void)?

    private let viewFactory: ViewFactory
    private let navigationPresenter: NavigationPresenter

    init(viewFactory: ViewFactory,
         navigationPresenter: NavigationPresenter) {
        self.viewFactory = viewFactory
        self.navigationPresenter = navigationPresenter
    }

    func start() -> ChatViewController {
        let viewController = makeChatViewController()
        return viewController
    }

    private func makeChatViewController() -> ChatViewController {
        let viewModel = ChatViewModel(alertTexts: viewFactory.theme.alertTexts)
        viewModel.delegate = { [weak self] event in
            switch event {
            case .back:
                self?.delegate?(.back)
            case .finished:
                self?.delegate?(.finished)
            }
        }
        return ChatViewController(viewModel: viewModel,
                                  viewFactory: viewFactory)
    }
}
