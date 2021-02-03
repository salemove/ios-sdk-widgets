import SalemoveSDK

class ChatCoordinator: SubFlowCoordinator, FlowCoordinator {
    enum DelegateEvent {
        case back
        case engaged(operatorImageUrl: String?)
        case audioUpgradeAccepted(AnswerWithSuccessBlock)
        case call
        case finished
    }

    var delegate: ((DelegateEvent) -> Void)?

    private let interactor: Interactor
    private let viewFactory: ViewFactory
    private let navigationPresenter: NavigationPresenter
    private let callProvider: Provider<Call?>

    init(interactor: Interactor,
         viewFactory: ViewFactory,
         navigationPresenter: NavigationPresenter,
         callProvider: Provider<Call?>) {
        self.interactor = interactor
        self.viewFactory = viewFactory
        self.navigationPresenter = navigationPresenter
        self.callProvider = callProvider
    }

    func start() -> ChatViewController {
        let viewController = makeChatViewController()
        return viewController
    }

    private func makeChatViewController() -> ChatViewController {
        let viewModel = ChatViewModel(interactor: interactor,
                                      alertConf: viewFactory.theme.alertConf,
                                      callProvider: callProvider)
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
            case .audioUpgradeAccepted(let answer):
                self?.delegate?(.audioUpgradeAccepted(answer))
            case .call:
                self?.delegate?(.call)
            }
        }
        return ChatViewController(viewModel: viewModel,
                                  viewFactory: viewFactory)
    }
}
