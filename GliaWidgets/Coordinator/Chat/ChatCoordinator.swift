final class ChatCoordinator: SubFlowCoordinator, FlowCoordinator {
    enum DelegateEvent {
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
        let viewModel = ChatViewModel()
        return ChatViewController(viewModel: viewModel,
                                  viewFactory: viewFactory)
    }
}
