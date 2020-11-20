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
        case .push(let navigationController):
            return NavigationPresenter(with: navigationController)
        case .present:
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
                self?.coordinatorFinished(navigationPresenter: navigationPresenter)
            }
        }
        startCoordinator(coordinator,
                         navigationPresenter: navigationPresenter)
    }

    private func startCoordinator(_ coordinator: ChatCoordinator,
                                  navigationPresenter: NavigationPresenter) {
        pushCoordinator(coordinator)
        let viewController = coordinator.start()

        switch presentationKind {
        case .push:
            navigationPresenter.push(viewController)
        case .present(let presentingViewController):
            navigationPresenter.push(viewController, animated: false)
            presentingViewController.present(navigationPresenter.navigationController,
                                             animated: true,
                                             completion: nil)
        }
    }

    private func coordinatorFinished(navigationPresenter: NavigationPresenter) {
        popCoordinator()

        switch presentationKind {
        case .push:
            navigationPresenter.pop()
        case .present:
            navigationPresenter.dismiss()
        }
    }
}
