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
    private let chatCallProvider = ValueProvider<Call?>(with: nil)
    private let unreadMessages = ValueProvider<Int>(with: 0)
    private let isWindowVisible = ValueProvider<Bool>(with: false)
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
            let chatViewController = startChat(withAction: .startEngagement,
                                               showsCallBubble: false)
            engagement = .chat(chatViewController)
            navigationPresenter.setViewControllers([chatViewController],
                                                   animated: false)
        case .audioCall, .videoCall:
            let kind: CallKind = engagementKind == .audioCall
                ? .audio
                : .video
            let call = Call(kind)
            let chatViewController = startChat(withAction: .none,
                                               showsCallBubble: true)
            let callViewController = startCall(call, withAction: .engagement)
            engagement = .call(callViewController,
                               chatViewController,
                               .none)
            navigationPresenter.setViewControllers([callViewController],
                                                   animated: false)
        }

        let bubbleView = viewFactory.makeBubbleView()
        unreadMessages.addObserver(self) { unreadCount, _ in
            bubbleView.setBadge(itemCount: unreadCount)
        }
        presentWindow(bubbleView: bubbleView, animated: true)
        gliaDelegate?.event(.started)
    }

    private func end() {
        window?.endEditing(true)
        dismissWindow(animated: true) {
            self.window = nil
            self.engagement = .none
            self.navigationPresenter.setViewControllers([], animated: false)
            self.removeAllCoordinators()
            self.gliaDelegate?.event(.ended)
        }
    }

    private func startChat(withAction startAction: ChatViewModel.StartAction, showsCallBubble: Bool) -> ChatViewController {
        let coordinator = ChatCoordinator(
            interactor: interactor,
            viewFactory: viewFactory,
            navigationPresenter: navigationPresenter,
            call: chatCallProvider,
            unreadMessages: unreadMessages,
            showsCallBubble: showsCallBubble,
            isWindowVisible: isWindowVisible,
            startAction: startAction
        )
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
            case .mediaUpgradeAccepted(offer: let offer, answer: let answer):
                self?.mediaUpgradeAccepted(offer: offer, answer: answer)
            case .call:
                switch self?.engagement {
                case .call(let callViewController, _, let upgradedFrom):
                    switch upgradedFrom {
                    case .none:
                        self?.navigationController.popToViewController(callViewController, animated: true)
                    case .chat:
                        self?.navigationPresenter.push(callViewController, animated: true)
                    }
                default:
                    break
                }
            case .finished:
                self?.popCoordinator()
                self?.end()
            }
        }
        pushCoordinator(coordinator)

        return coordinator.start()
    }

    private func startCall(_ call: Call,
                           withAction startAction: CallViewModel.StartAction) -> CallViewController {
        let coordinator = CallCoordinator(
            interactor: interactor,
            viewFactory: viewFactory,
            navigationPresenter: navigationPresenter,
            call: call,
            unreadMessages: unreadMessages,
            startAction: startAction
        )
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
            case .minimize:
                self?.window?.minimize(animated: true)
            case .finished:
                self?.popCoordinator()
                self?.end()
            }
        }
        pushCoordinator(coordinator)

        return coordinator.start()
    }

    private func presentWindow(bubbleView: BubbleView, animated: Bool) {
        guard window == nil else { return }

        let window = GliaWindow(bubbleView: bubbleView, delegate: self)
        window.rootViewController = navigationController
        window.isHidden = false
        window.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
        self.window = window
        isWindowVisible.value = true

        UIView.animate(withDuration: animated ? 0.4 : 0.0,
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
        isWindowVisible.value = false
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
    private func mediaUpgradeAccepted(offer: MediaUpgradeOffer, answer: @escaping AnswerWithSuccessBlock) {
        switch engagement {
        case .chat(let chatViewController):
            guard let kind = CallKind(with: offer) else { return }
            let call = Call(kind)
            let callViewController = startCall(call, withAction: .call(offer: offer, answer: answer))
            engagement = .call(callViewController,
                               chatViewController,
                               .chat)
            chatCallProvider.value = call
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
            isWindowVisible.value = false
            gliaDelegate?.event(.minimized)
        case .maximized:
            isWindowVisible.value = true
            gliaDelegate?.event(.maximized)
        }
    }
}
