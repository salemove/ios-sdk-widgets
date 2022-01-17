import UIKit

final class AppCoordinator: UIViewControllerCoordinator {
    enum Delegate {
        case started
        case ended
        case engagementChanged(EngagementKind)
        case minimized
        case maximized
    }

    var delegate: ((Delegate) -> Void)?
    var engagementKind: EngagementKind {
        didSet {
            delegate?(.engagementChanged(engagementKind))
        }
    }

    private let interactor: Interactor
    private let viewFactory: ViewFactory
    private let features: Features
    private let sceneProvider: SceneProvider?
    private let screenShareHandler: ScreenShareHandler
    private let messageDispatcher: MessageDispatcher

    private var gliaViewController: GliaViewController?

    private lazy var window: UIWindow? = {
        if #available(iOS 13, *), let sceneProvider = sceneProvider {
            return sceneProvider.windowScene()?.windows.filter(\.isKeyWindow).first
        } else {
            return UIApplication.shared.keyWindow
        }
    }()

    private var presenter: UIViewController {
        guard let window = window else {
            fatalError("Could not find key UIWindow to present on")
        }

        guard var presenter = window.rootViewController else {
            fatalError("Could not find UIViewController to present on")
        }

        while let presentedViewController = presenter.presentedViewController {
            presenter = presentedViewController
        }

        return presenter
    }

    init(
        engagementKind: EngagementKind,
        interactor: Interactor,
        viewFactory: ViewFactory,
        features: Features,
        sceneProvider: SceneProvider?
    ) {
        self.engagementKind = engagementKind
        self.interactor = interactor
        self.viewFactory = viewFactory
        self.features = features
        self.sceneProvider = sceneProvider
        self.screenShareHandler = ScreenShareHandler()
        self.messageDispatcher = MessageDispatcher(
            interactor: interactor,
            chatStorage: ChatStorage()
        )
    }

    @discardableResult
    override func start() -> Coordinated {
        let viewController = createGliaViewController()
        self.gliaViewController = viewController

        presentEngagement()

        return viewController
    }

    func end() {
        gliaViewController?.dismiss(
            animated: true,
            completion: { [weak self] in
                self?.delegate?(.ended)
                self?.engagementKind = .none
            }
        )
    }

    private func presentEngagement() {
        let coordinator = EngagementCoordinator(
            interactor: interactor,
            viewFactory: viewFactory,
            screenShareHandler: screenShareHandler,
            engagementKind: engagementKind,
            messageDispatcher: messageDispatcher
        )

        coordinator.delegate = { [weak self] in
            switch $0 {
            case .minimize:
                self?.gliaViewController?.minimize(animated: true)

            case .engaged(operatorImageUrl: let operatorImageUrl):
                self?.gliaViewController?.bubbleKind = .userImage(url: operatorImageUrl)

            case .started:
                self?.delegate?(.started)

            case .ended:
                self?.end()

            case .engagementChanged(let engagementKind):
                self?.engagementKind = engagementKind
            }
        }

        let viewController = coordinate(to: coordinator)

        gliaViewController?.insertChild(viewController)
        gliaViewController?.maximize(animated: true)
    }

    private func createGliaViewController() -> GliaViewController {
        if #available(iOS 13.0, *), let sceneProvider = sceneProvider {
            return GliaViewController(
                bubbleView: viewFactory.makeBubbleView(),
                delegate: self,
                sceneProvider: sceneProvider,
                features: features
            )
        } else {
            return GliaViewController(
                bubbleView: viewFactory.makeBubbleView(),
                delegate: self,
                features: features
            )
        }
    }
}

extension AppCoordinator: GliaViewControllerDelegate {
    func event(_ event: GliaViewControllerEvent) {
        switch event {
        case .minimized:
            gliaViewController?.presentingViewController?.dismiss(animated: true)
            delegate?(.minimized)

        case .maximized:
            guard let gliaViewController = gliaViewController else { return }
            presenter.present(gliaViewController, animated: true)
            delegate?(.maximized)
        }
    }
}

extension AppCoordinator {
    func maximize() {
        gliaViewController?.maximize(animated: true)
    }
}
