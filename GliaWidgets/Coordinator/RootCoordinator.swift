import UIKit
import SalemoveSDK

class RootCoordinator: SubFlowCoordinator, FlowCoordinator {
    enum DelegateEvent {}

    private enum Engagement {
        case none
        case chat(ChatViewController)
        case call(CallViewController, ChatViewController)
    }

    var delegate: ((DelegateEvent) -> Void)?

    private let interactor: Interactor
    private let viewFactory: ViewFactory
    private weak var gliaDelegate: GliaDelegate?
    private let engagementKind: EngagementKind
    private var engagement: Engagement = .none
    private let navigationController = NavigationController()
    private let navigationPresenter: NavigationPresenter
    private var window: GliaWindow?
    private var bubbleView: BubbleView?
    private let kBubbleViewSize: CGFloat = 60.0

    init(interactor: Interactor,
         viewFactory: ViewFactory,
         gliaDelegate: GliaDelegate?,
         engagementKind: EngagementKind) {
        self.interactor = interactor
        self.viewFactory = viewFactory
        self.gliaDelegate = gliaDelegate
        self.engagementKind = engagementKind
        self.navigationPresenter = NavigationPresenter(with: navigationController)

        navigationController.modalPresentationStyle = .fullScreen
        navigationController.isNavigationBarHidden = true
    }

    func start() {
        switch engagementKind {
        case .chat:
            let chatViewController = startChat()
            engagement = .chat(chatViewController)
        case .audioCall:
            let chatViewController = startChat()
            let callViewController = startCall(.audio,
                                               startAction: .default)
            engagement = .call(callViewController,
                               chatViewController)
        case .videoCall:
            break
        }

        presentWindow(animated: true)
        gliaDelegate?.event(.started)
    }

    private func end() {
        dismissWindow(animated: true)
        gliaDelegate?.event(.ended)
        engagement = .none
    }

    private func startChat() -> ChatViewController {
        let coordinator = ChatCoordinator(interactor: interactor,
                                          viewFactory: viewFactory,
                                          navigationPresenter: navigationPresenter)
        coordinator.delegate = { [weak self] event in
            switch event {
            case .back:
                self?.minimizeWindow(animated: true)
            case .operatorImage(url: let url):
                self?.bubbleView?.kind = .userImage(url: url)
            case .finished:
                self?.popCoordinator()
                self?.navigationPresenter.pop()
                self?.end()
            case .audioUpgradeAccepted(let answer):
                self?.audioUpgradeAccepted(answer: answer)
            }
        }

        let viewController = coordinator.start()

        pushCoordinator(coordinator)
        navigationPresenter.push(viewController, animated: false)

        return viewController
    }

    private func startCall(_ callKind: CallViewModel.CallKind,
                           startAction: CallViewModel.StartAction) -> CallViewController {
        let coordinator = CallCoordinator(interactor: interactor,
                                          viewFactory: viewFactory,
                                          navigationPresenter: navigationPresenter,
                                          callKind: callKind,
                                          startAction: startAction)
        coordinator.delegate = { [weak self] event in
            switch event {
            case .back:
                self?.minimizeWindow(animated: true)
            case .operatorImage(url: let url):
                self?.bubbleView?.kind = .userImage(url: url)
            case .finished:
                self?.popCoordinator()
                self?.navigationPresenter.pop()
                self?.end()
            case .chat:
                break // show chat
            }
        }

        let viewController = coordinator.start()

        pushCoordinator(coordinator)
        navigationPresenter.push(viewController, animated: false)

        return viewController
    }

    private func presentWindow(animated: Bool) {
        guard window == nil else { return }

        let window = GliaWindow(delegate: self)
        window.rootViewController = navigationController
        window.isHidden = false
        window.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
        self.window = window

        UIView.animate(withDuration: animated ? 0.5 : 0.0,
                       delay: 0.0,
                       usingSpringWithDamping: 0.8,
                       initialSpringVelocity: 0.5,
                       options: .curveEaseInOut,
                       animations: {
                        window.transform = .identity
                       }, completion: nil)
    }

    private func minimizeWindow(animated: Bool) {
        let bubbleView = viewFactory.makeBubbleView()
        self.bubbleView = bubbleView
        window?.minimize(using: bubbleView, animated: true)
    }

    private func dismissWindow(animated: Bool) {
        guard let window = window else { return }

        UIView.animate(withDuration: animated ? 0.4 : 0.0,
                       delay: 0.0,
                       options: .curveEaseInOut) {
            window.alpha = 0.0
        } completion: { _ in
            self.window?.endEditing(true)
            self.window = nil
            self.bubbleView = nil
        }
    }
}

extension RootCoordinator {
    private func audioUpgradeAccepted(answer: @escaping AnswerWithSuccessBlock) {
        switch engagement {
        case .chat(let chatViewController):
            let callViewController = startCall(.audio,
                                               startAction: .startAudio(answer))
            engagement = .call(callViewController,
                               chatViewController)
        default:
            break
        }
    }
}

extension RootCoordinator: GliaWindowDelegate {
    func event(_ event: GliaWindowEvent) {
        switch event {
        case .minimized:
            gliaDelegate?.event(.minimized)
        case .maximized:
            gliaDelegate?.event(.maximized)
        }
    }
}
