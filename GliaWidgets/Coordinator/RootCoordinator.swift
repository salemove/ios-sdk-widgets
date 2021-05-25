import SalemoveSDK
import UIKit

class RootCoordinator: SubFlowCoordinator, FlowCoordinator {
    enum DelegateEvent {
        case started
        case engagementChanged(EngagementKind)
        case ended
        case minimized
        case maximized
    }

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

    var engagementKind: EngagementKind {
        didSet { delegate?(.engagementChanged(engagementKind)) }
    }

    private let interactor: Interactor
    private let viewFactory: ViewFactory
    private weak var sceneProvider: SceneProvider?
    private var engagement: Engagement = .none
    private let chatCall = ObservableValue<Call?>(with: nil)
    private let unreadMessages = ObservableValue<Int>(with: 0)
    private let isWindowVisible = ObservableValue<Bool>(with: false)
    private let navigationController = NavigationController()
    private let navigationPresenter: NavigationPresenter
    private var window: GliaWindow?
    private let kBubbleViewSize: CGFloat = 60.0

    init(
        interactor: Interactor,
        viewFactory: ViewFactory,
        sceneProvider: SceneProvider?,
        engagementKind: EngagementKind
    ) {
        self.interactor = interactor
        self.viewFactory = viewFactory
        self.sceneProvider = sceneProvider
        self.engagementKind = engagementKind
        self.navigationPresenter = NavigationPresenter(with: navigationController)
        navigationController.modalPresentationStyle = .fullScreen
        navigationController.isNavigationBarHidden = true
    }

    func start() {
        switch engagementKind {
        case .none:
            break
        case .chat:
            let chatViewController = startChat(
                withAction: .startEngagement,
                showsCallBubble: false
            )
            engagement = .chat(chatViewController)
            navigationPresenter.setViewControllers(
                [chatViewController],
                animated: false
            )
        case .audioCall, .videoCall:
            let kind: CallKind = engagementKind == .audioCall
                ? .audio
                : .video
            let call = Call(kind)
            call.kind.addObserver(self) { _, _ in
                self.engagementKind = EngagementKind(with: call.kind.value)
            }
            let chatViewController = startChat(
                withAction: .none,
                showsCallBubble: true
            )
            let callViewController = startCall(call, withAction: .engagement)
            engagement = .call(
                callViewController,
                chatViewController,
                .none
            )
            navigationPresenter.setViewControllers(
                [callViewController],
                animated: false
            )
        }

        let bubbleView = viewFactory.makeBubbleView()
        unreadMessages.addObserver(self) { unreadCount, _ in
            bubbleView.setBadge(itemCount: unreadCount)
        }
        presentWindow(bubbleView: bubbleView, animated: true)
        delegate?(.started)
    }

    private func end() {
        window?.endEditing(true)
        dismissWindow(animated: true) {
            self.window = nil
            self.engagement = .none
            self.navigationPresenter.setViewControllers([], animated: false)
            self.removeAllCoordinators()
            self.engagementKind = .none
            self.delegate?(.ended)
        }
    }

    private func startChat(
        withAction startAction: ChatViewModel.StartAction,
        showsCallBubble: Bool
    ) -> ChatViewController {
        let coordinator = ChatCoordinator(
            interactor: interactor,
            viewFactory: viewFactory,
            navigationPresenter: navigationPresenter,
            call: chatCall,
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
            case .engaged(let operatorImageUrl):
                self?.window?.bubbleKind = .userImage(url: operatorImageUrl)
            case .mediaUpgradeAccepted(let offer, let answer):
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

    private func startCall(
        _ call: Call,
        withAction startAction: CallViewModel.StartAction
    ) -> CallViewController {
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
            case .engaged(let operatorImageUrl):
                self?.window?.bubbleKind = .userImage(url: operatorImageUrl)
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
}

extension RootCoordinator {
    private func presentWindow(bubbleView: BubbleView, animated: Bool) {
        guard window == nil else { return }

        let window = makeWindow(bubbleView: bubbleView)
        window.rootViewController = navigationController
        window.isHidden = false
        window.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
        self.window = window
        isWindowVisible.value = true

        UIView.animate(
            withDuration: animated ? 0.4 : 0.0,
            delay: 0.0,
            usingSpringWithDamping: 0.8,
            initialSpringVelocity: 0.5,
            options: .curveEaseInOut,
            animations: {
                window.transform = .identity
            }
        )
    }

    private func dismissWindow(animated: Bool, completion: @escaping () -> Void) {
        guard let window = window else { return }
        isWindowVisible.value = false
        UIView.animate(
            withDuration: animated ? 0.5 : 0.0,
            delay: 0.0,
            options: .curveEaseInOut,
            animations: { window.alpha = 0.0 },
            completion: { _ in completion() }
        )
    }

    private func makeWindow(bubbleView: BubbleView) -> GliaWindow {
        if #available(iOS 13.0, *) {
            if let windowScene = windowScene() {
                return GliaWindow(
                    bubbleView: bubbleView,
                    windowScene: windowScene,
                    delegate: self
                )
            } else {
                return GliaWindow(
                    bubbleView: bubbleView,
                    delegate: self
                )
            }
        } else {
            return GliaWindow(
                bubbleView: bubbleView,
                delegate: self
            )
        }
    }

    @available(iOS 13.0, *)
    private func windowScene() -> UIWindowScene? {
        if let sceneProvider = sceneProvider {
            return sceneProvider.windowScene()
        } else {
            let scene = UIApplication.shared
                .connectedScenes
                .filter { $0.activationState == .foregroundActive }
                .first
            return scene as? UIWindowScene
        }
    }
}

extension RootCoordinator {
    private func mediaUpgradeAccepted(
        offer: MediaUpgradeOffer,
        answer: @escaping AnswerWithSuccessBlock
    ) {
        switch engagement {
        case .chat(let chatViewController):
            guard let kind = CallKind(with: offer) else { return }
            let call = Call(kind)
            call.kind.addObserver(self) { _, _ in
                self.engagementKind = EngagementKind(with: call.kind.value)
            }
            let callViewController = startCall(call, withAction: .call(offer: offer, answer: answer))
            engagement = .call(
                callViewController,
                chatViewController,
                .chat
            )
            chatCall.value = call
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
            delegate?(.minimized)
        case .maximized:
            isWindowVisible.value = true
            delegate?(.maximized)
        }
    }
}

extension EngagementKind {
    init(with kind: CallKind) {
        switch kind {
        case .audio:
            self = .audioCall
        case .video:
            self = .videoCall
        }
    }
}
