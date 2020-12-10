import UIKit

class RootCoordinator: SubFlowCoordinator, FlowCoordinator {
    enum DelegateEvent {}

    var delegate: ((DelegateEvent) -> Void)?

    private let viewFactory: ViewFactory
    private let engagementKind: EngagementKind
    private let navigationController = NavigationController()
    private let navigationPresenter: NavigationPresenter
    private let window: GliaWindow
    private let minimizedView: UIView
    private let kMinimizedViewSize: CGFloat = 80.0

    init(viewFactory: ViewFactory,
         engagementKind: EngagementKind) {
        self.viewFactory = viewFactory
        self.engagementKind = engagementKind
        self.navigationPresenter = NavigationPresenter(with: navigationController)
        self.minimizedView = viewFactory.makeMinimizedOperatorImageView(ofSize: kMinimizedViewSize)
        self.window = GliaWindow(minimizedView: minimizedView)

        window.rootViewController = navigationController
        navigationController.modalPresentationStyle = .fullScreen
        navigationController.isNavigationBarHidden = true
    }

    func start() {
        switch engagementKind {
        case .chat:
            startChat()
        case .audioCall:
            break
        case .videoCall:
            break
        }

        //window.isHidden = false
        window.makeKeyAndVisible()
    }

    private func startChat() {
        let coordinator = ChatCoordinator(viewFactory: viewFactory,
                                          navigationPresenter: navigationPresenter)
        coordinator.delegate = { [weak self] event in
            switch event {
            case .finished:
                self?.popCoordinator()
                self?.navigationPresenter.pop()
            }
        }

        let viewController = coordinator.start()

        pushCoordinator(coordinator)
        navigationPresenter.push(viewController, animated: false)
    }
}
