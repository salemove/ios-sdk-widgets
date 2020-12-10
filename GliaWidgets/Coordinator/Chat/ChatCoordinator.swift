class ChatCoordinator: SubFlowCoordinator, FlowCoordinator {
    enum DelegateEvent {
        case finished
    }

    var delegate: ((DelegateEvent) -> Void)?

    private let viewFactory: ViewFactory
    private let navigationPresenter: NavigationPresenter
    private let presentationKind: PresentationKind

    init(viewFactory: ViewFactory,
         navigationPresenter: NavigationPresenter,
         presentationKind: PresentationKind) {
        self.viewFactory = viewFactory
        self.navigationPresenter = navigationPresenter
        self.presentationKind = presentationKind
    }

    func start() -> ChatViewController {
        let viewController = makeChatViewController()
        return viewController
    }

    private func makeChatViewController() -> ChatViewController {
        let viewModel = ChatViewModel(alertTexts: viewFactory.theme.alertTexts)
        viewModel.delegate = { [weak self] event in
            switch event {
            case .finished:
                self?.delegate?(.finished)
            }
        }
        return ChatViewController(viewModel: viewModel,
                                  viewFactory: viewFactory,
                                  presentationKind: presentationKind)
    }
}
