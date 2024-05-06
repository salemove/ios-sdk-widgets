import UIKit

class MediaSelectorCoordinator: SubFlowCoordinator, FlowCoordinator, GliaViewControllerDelegate {
    var delegate: ((DelegateEvent) -> Void)?
    private let navigationController = NavigationController()
    let navigationPresenter: NavigationPresenter
    let viewFactory: ViewFactory
    var gliaViewController: GliaViewController?
    var features: Features = .all
    let environment: Environment
    let gliaPresenter: GliaPresenter
    private(set) weak var sceneProvider: SceneProvider?
    let interactor: Interactor

    init(
        interactor: Interactor,
        viewFactory: ViewFactory,
        sceneProvider: SceneProvider?,
        environment: Environment
    ) {
        self.interactor = interactor
        self.navigationPresenter = NavigationPresenter(with: navigationController)
        self.viewFactory = viewFactory
        self.sceneProvider = sceneProvider
        self.sceneProvider = sceneProvider
        self.gliaPresenter = GliaPresenter(
            environment: .init(
                appWindowsProvider: .init(
                    uiApplication: environment.uiApplication,
                    sceneProvider: sceneProvider
                ),
                log: environment.log
            )
        )
        self.environment = environment

        navigationController.modalPresentationStyle = .fullScreen
        navigationController.isNavigationBarHidden = true
    }

    func start() -> MediaSelectorViewController? {
        let mediaSelectorViewController = MediaSelectorViewController(queueInformation: interactor.queueInformation)
        mediaSelectorViewController.delegate = { [weak self] event in
            switch event {
            case .queueSelected(let queueInformation):
                self?.delegate?(.queueSelected(queueInformation))
            }
        }

        navigationPresenter.setViewControllers(
            [mediaSelectorViewController],
            animated: false
        )

        let bubbleView = viewFactory.makeBubbleView()

        gliaViewController = makeGliaView(
            bubbleView: bubbleView,
            features: features
        )
        gliaViewController?.insertChild(navigationController)
        event(.maximized)

        guard let gliaViewController = gliaViewController else { return nil }
        gliaPresenter.present(gliaViewController, animated: true) { [weak self] in
            
        }

        return mediaSelectorViewController
    }

    private func makeGliaView(
        bubbleView: BubbleView,
        features: Features
    ) -> GliaViewController {
        let animate: (
            _ animated: Bool,
            _ animations: @escaping () -> Void,
            _ completion: @escaping (
                Bool
            ) -> Void
        ) -> Void = { animated, animations, completion in
            UIView.animate(
                withDuration: animated ? 0.4 : 0.0,
                delay: 0.0,
                usingSpringWithDamping: 0.8,
                initialSpringVelocity: 0.7,
                options: .curveEaseInOut,
                animations: animations,
                completion: completion
            )
        }

        if #available(iOS 13.0, *) {
            if let sceneProvider = sceneProvider {
                return GliaViewController(
                    bubbleView: bubbleView,
                    delegate: self,
                    sceneProvider: sceneProvider,
                    features: features,
                    environment: .init(
                        uiApplication: environment.uiApplication,
                        uiScreen: environment.uiScreen,
                        log: environment.log,
                        animate: animate
                    )
                )
            } else {
                return GliaViewController(
                    bubbleView: bubbleView,
                    delegate: self,
                    features: features,
                    environment: .init(
                        uiApplication: environment.uiApplication,
                        uiScreen: environment.uiScreen,
                        log: environment.log,
                        animate: animate
                    )
                )
            }
        } else {
            return GliaViewController(
                bubbleView: bubbleView,
                delegate: self,
                features: features,
                environment: .init(
                    uiApplication: environment.uiApplication,
                    uiScreen: environment.uiScreen,
                    log: environment.log,
                    animate: animate
                )
            )
        }
    }

    func event(_ event: GliaViewControllerEvent) {

    }
}

extension MediaSelectorCoordinator {
    enum DelegateEvent {
        case queueSelected(QueueInformation)
    }
}

extension MediaSelectorCoordinator {
    struct Environment {
        let uiApplication: UIKitBased.UIApplication
        let uiScreen: UIKitBased.UIScreen
        let log: CoreSdkClient.Logger
    }
}

