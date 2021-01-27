import UIKit
import SalemoveSDK

class RootCoordinator: SubFlowCoordinator, FlowCoordinator {
    enum DelegateEvent {}

    private enum Engagement {
        case none
        case chat(ChatViewController)
        case call(CallViewController, ChatViewController, UpgradedFrom)
    }

    private enum UpgradedFrom {
        case none
        case chat
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
            navigationPresenter.setViewControllers([chatViewController],
                                                   animated: false)
        case .audioCall:
            let chatViewController = startChat()
            let callViewController = startCall(.audio,
                                               startAction: .default)
            engagement = .call(callViewController,
                               chatViewController,
                               .none)
            navigationPresenter.setViewControllers([callViewController],
                                                   animated: false)
        case .videoCall:
            break
        }

        presentWindow(animated: true)
        gliaDelegate?.event(.started)
    }

    private func end() {
        window?.endEditing(true)
        dismissWindow(animated: true) {
            self.window = nil
            self.gliaDelegate?.event(.ended)
            self.engagement = .none
            self.navigationPresenter.setViewControllers([], animated: false)
        }
    }

    private func startChat() -> ChatViewController {
        let coordinator = ChatCoordinator(interactor: interactor,
                                          viewFactory: viewFactory,
                                          navigationPresenter: navigationPresenter)
        coordinator.delegate = { [weak self] event in
            switch event {
            case .back:
                switch self?.engagement {
                case .chat:
                    self?.window?.minimize(animated: true)
                case .call(let callViewController, _, let upgradedFrom):
                    if upgradedFrom == .chat {
                        self?.window?.minimize(animated: true)
                    } else {
                        self?.navigationPresenter.pop(to: callViewController, animated: true)
                    }
                default:
                    break
                }
            case .engaged(operatorImageUrl: let url):
                self?.window?.bubbleKind = .userImage(url: url)
            case .finished:
                self?.popCoordinator()
                self?.end()
            case .audioUpgradeAccepted(let answer):
                self?.audioUpgradeAccepted(answer: answer)
            }
        }
        pushCoordinator(coordinator)

        return coordinator.start()
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
                switch self?.engagement {
                case .call(_, let chatViewController, let upgradedFrom):
                    if upgradedFrom == .chat {
                        self?.navigationPresenter.pop(to: chatViewController, animated: true)
                    } else {
                        self?.window?.minimize(animated: true)
                    }
                default:
                    break
                }
            case .engaged(operatorImageUrl: let url):
                self?.window?.bubbleKind = .userImage(url: url)
            case .finished:
                self?.popCoordinator()
                self?.end()
            case .chat:
                switch self?.engagement {
                case .call(_, let chatViewController, let upgradedFrom):
                    if upgradedFrom == .chat {
                        self?.navigationPresenter.pop(to: chatViewController, animated: true)
                    } else {
                        self?.navigationPresenter.push(chatViewController, animated: true)
                    }
                default:
                    break
                }
            }
        }
        pushCoordinator(coordinator)

        return coordinator.start()
    }

    private func presentWindow(animated: Bool) {
        guard window == nil else { return }

        let bubbleView = viewFactory.makeBubbleView()
        let window = GliaWindow(bubbleView: bubbleView, delegate: self)
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

    private func dismissWindow(animated: Bool, completion: @escaping () -> Void) {
        guard let window = window else { return }

        UIView.animate(withDuration: animated ? 0.5 : 0.0,
                       delay: 0.0,
                       options: .curveEaseInOut) {
            window.alpha = 0.0
        } completion: { _ in
            completion()
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
                               chatViewController,
                               .chat)
            navigationPresenter.push(callViewController)
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
