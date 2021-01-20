class CallCoordinator: SubFlowCoordinator, FlowCoordinator {
    enum DelegateEvent {
        case back
        case operatorImage(url: String?)
        case chat
        case finished
    }

    var delegate: ((DelegateEvent) -> Void)?

    private let interactor: Interactor
    private let viewFactory: ViewFactory
    private let navigationPresenter: NavigationPresenter

    init(interactor: Interactor,
         viewFactory: ViewFactory,
         navigationPresenter: NavigationPresenter) {
        self.interactor = interactor
        self.viewFactory = viewFactory
        self.navigationPresenter = navigationPresenter
    }

    func start() -> CallViewController {
        let viewController = makeCallViewController()
        return viewController
    }

    private func makeCallViewController() -> CallViewController {
        let viewModel = CallViewModel(interactor: interactor,
                                      alertConf: viewFactory.theme.alertConf)
        viewModel.engagementDelegate = { [weak self] event in
            switch event {
            case .back:
                self?.delegate?(.back)
            case .operatorImage(url: let url):
                self?.delegate?(.operatorImage(url: url))
            case .finished:
                self?.delegate?(.finished)
            }
        }
        viewModel.delegate = { [weak self] event in
            switch event {
            case .chat:
                self?.delegate?(.chat)
            }
        }
        return CallViewController(viewModel: viewModel,
                                  viewFactory: viewFactory)
    }
}
