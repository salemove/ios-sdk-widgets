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
    private let callKind: CallKind
    private let startAction: CallViewModel.StartAction
    private let callStateProvider: Provider<CallState>

    init(interactor: Interactor,
         viewFactory: ViewFactory,
         navigationPresenter: NavigationPresenter,
         callKind: CallKind,
         startAction: CallViewModel.StartAction,
         callStateProvider: Provider<CallState>) {
        self.interactor = interactor
        self.viewFactory = viewFactory
        self.navigationPresenter = navigationPresenter
        self.callKind = callKind
        self.startAction = startAction
        self.callStateProvider = callStateProvider
    }

    func start() -> CallViewController {
        let viewController = makeCallViewController(callKind: callKind,
                                                    startAction: startAction)
        return viewController
    }

    private func makeCallViewController(callKind: CallKind,
                                        startAction: CallViewModel.StartAction) -> CallViewController {
        let viewModel = CallViewModel(interactor: interactor,
                                      alertConf: viewFactory.theme.alertConf,
                                      callKind: callKind,
                                      startAction: startAction,
                                      callStateProvider: callStateProvider)
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
