class CallCoordinator: SubFlowCoordinator, FlowCoordinator {
    enum DelegateEvent {
        case back
        case engaged(operatorImageUrl: String?)
        case chat
        case minimize
        case finished
    }

    var delegate: ((DelegateEvent) -> Void)?

    private let interactor: Interactor
    private let viewFactory: ViewFactory
    private let navigationPresenter: NavigationPresenter
    private let call: Call
    private let unreadMessages: ValueProvider<Int>
    private let startAction: CallViewModel.StartAction

    init(interactor: Interactor,
         viewFactory: ViewFactory,
         navigationPresenter: NavigationPresenter,
         call: Call,
         unreadMessages: ValueProvider<Int>,
         startAction: CallViewModel.StartAction) {
        self.interactor = interactor
        self.viewFactory = viewFactory
        self.navigationPresenter = navigationPresenter
        self.call = call
        self.unreadMessages = unreadMessages
        self.startAction = startAction
    }

    func start() -> CallViewController {
        let viewController = makeCallViewController(call: call,
                                                    startAction: startAction)
        return viewController
    }

    private func makeCallViewController(call: Call,
                                        startAction: CallViewModel.StartAction) -> CallViewController {
        let viewModel = CallViewModel(
            interactor: interactor,
            alertConfiguration: viewFactory.theme.alertConfiguration,
            call: call,
            unreadMessages: unreadMessages,
            startWith: startAction
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
            case .chat:
                self?.delegate?(.chat)
            case .minimize:
                self?.delegate?(.minimize)
            }
        }
        return CallViewController(viewModel: viewModel,
                                  viewFactory: viewFactory)
    }
}
