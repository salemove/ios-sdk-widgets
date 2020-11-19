final class RootCoordinator: SubFlowCoordinator, FlowCoordinator {
    enum DelegateEvent {}

    var delegate: ((DelegateEvent) -> Void)?

    private let viewFactory: ViewFactory
    private let engagementKind: EngagementKind
    private let presentationKind: PresentationKind

    init(viewFactory: ViewFactory,
         engagementKind: EngagementKind,
         presentationKind: PresentationKind) {
        self.viewFactory = viewFactory
        self.engagementKind = engagementKind
        self.presentationKind = presentationKind
    }

    func start() {
        let navigationPresenter = makeNavigationPresenter()

        switch engagementKind {
        case .chat:
            startChat(with: navigationPresenter)
        case .audioCall:
            break
        case .videoCall:
            break
        }
    }

    private func makeNavigationPresenter() -> NavigationPresenter {
        switch presentationKind {
        case .pushTo(let navigationController):
            return NavigationPresenter(with: navigationController)
        case .presentFrom:
            let navigationController = NavigationController()
            navigationController.modalPresentationStyle = .fullScreen
            return NavigationPresenter(with: navigationController)
        }
    }

    private func startChat(with navigationPresenter: NavigationPresenter) {
        let coordinator = ChatCoordinator(viewFactory: viewFactory,
                                          navigationPresenter: navigationPresenter)
        coordinator.delegate = { [weak self] event in
            switch event {
            case .finished:
                self?.coordinatorFinished(with: navigationPresenter)
            }
        }
        startCoordinator(coordinator, with: navigationPresenter)
    }

    private func startCoordinator(_ coordinator: ChatCoordinator,
                                  with navigationPresenter: NavigationPresenter) {
        pushCoordinator(coordinator)
        let viewController = coordinator.start()

        switch presentationKind {
        case .pushTo:
            navigationPresenter.push(viewController)
        case .presentFrom(let presentingViewController):
            navigationPresenter.push(viewController, animated: false)
            presentingViewController.present(navigationPresenter.navigationController,
                                             animated: true,
                                             completion: nil)
        }
    }

    private func coordinatorFinished(with navigationPresenter: NavigationPresenter) {
        popCoordinator()

        switch presentationKind {
        case .pushTo:
            navigationPresenter.pop()
        case .presentFrom:
            navigationPresenter.dismiss()
        }
    }
}
