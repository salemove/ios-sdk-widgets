import UIKit

class RootCoordinator: SubFlowCoordinator, FlowCoordinator {
    enum DelegateEvent {}

    var delegate: ((DelegateEvent) -> Void)?

    private let interactor: Interactor
    private let viewFactory: ViewFactory
    private let engagementKind: EngagementKind
    private let navigationController = NavigationController()
    private let navigationPresenter: NavigationPresenter
    private var window: GliaWindow?
    private var minimizedView: UIView?
    private let kMinimizedViewSize = CGSize(width: 80.0, height: 80.0)

    init(interactor: Interactor,
         viewFactory: ViewFactory,
         engagementKind: EngagementKind) {
        self.interactor = interactor
        self.viewFactory = viewFactory
        self.engagementKind = engagementKind
        self.navigationPresenter = NavigationPresenter(with: navigationController)

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

        presentWindow(animated: true)
    }

    private func startChat() {
        let coordinator = ChatCoordinator(interactor: interactor,
                                          viewFactory: viewFactory,
                                          navigationPresenter: navigationPresenter)
        coordinator.delegate = { [weak self] event in
            switch event {
            case .back:
                self?.window?.setState(.minimized, animated: true)
            case .finished:
                self?.popCoordinator()
                self?.navigationPresenter.pop()
                self?.dismissWindow(animated: true)
            }
        }

        let viewController = coordinator.start()

        pushCoordinator(coordinator)
        navigationPresenter.push(viewController, animated: false)
    }

    private func makeWindow(with minimizedView: UIView) -> GliaWindow {
        let window = GliaWindow(minimizedView: minimizedView,
                                minimizedSize: kMinimizedViewSize)
        window.rootViewController = navigationController
        return window
    }

    private func presentWindow(animated: Bool) {
        guard window == nil else { return }

        let minimizedView = viewFactory.makeMinimizedOperatorImageView()
        self.minimizedView = minimizedView

        let window = makeWindow(with: minimizedView)
        self.window = window
        window.isHidden = false
        window.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)

        UIView.animate(withDuration: animated ? 0.5 : 0.0,
                       delay: 0.0,
                       usingSpringWithDamping: 0.8,
                       initialSpringVelocity: 0.5,
                       options: .curveEaseInOut,
                       animations: {
                        window.transform = .identity
                       }, completion: nil)
    }

    private func dismissWindow(animated: Bool) {
        guard let window = window else { return }

        UIView.animate(withDuration: animated ? 0.4 : 0.0,
                       delay: 0.0,
                       options: .curveEaseInOut) {
            window.alpha = 0.0
        } completion: { _ in
            self.window = nil
            self.minimizedView = nil
        }
    }
}
