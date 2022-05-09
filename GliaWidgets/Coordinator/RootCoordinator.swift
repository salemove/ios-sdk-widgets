import UIKit

class RootCoordinator: SubFlowCoordinator, FlowCoordinator {

    var delegate: ((DelegateEvent) -> Void)?

    var engagementKind: EngagementKind {
        didSet {
            delegate?(.engagementChanged(engagementKind))
        }
    }

    private let interactor: Interactor
    private let viewFactory: ViewFactory
    private weak var sceneProvider: SceneProvider?
    private var engagement: Engagement = .none
    private let chatCall = ObservableValue<Call?>(with: nil)
    private let unreadMessages = ObservableValue<Int>(with: 0)
    private let isWindowVisible = ObservableValue<Bool>(with: false)
    private let screenShareHandler = ScreenShareHandler()

    private let navigationController = NavigationController()
    private let navigationPresenter: NavigationPresenter
    private let gliaPresenter: GliaPresenter
    private var gliaViewController: GliaViewController?
    private let kBubbleViewSize: CGFloat = 60.0
    private let features: Features
    private let environment: Environment

    init(
        interactor: Interactor,
        viewFactory: ViewFactory,
        sceneProvider: SceneProvider?,
        engagementKind: EngagementKind,
        features: Features,
        environment: Environment
    ) {
        self.interactor = interactor
        self.viewFactory = viewFactory
        self.sceneProvider = sceneProvider
        self.engagementKind = engagementKind
        self.gliaPresenter = GliaPresenter(sceneProvider: sceneProvider)
        self.navigationPresenter = NavigationPresenter(with: navigationController)
        self.features = features
        self.environment = environment
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
                : .video(direction: .twoWay)

            let mediaType: CoreSdkClient.MediaType = engagementKind == .audioCall
                ? .audio
                : .video
            let call = Call(
                kind,
                environment: .init(
                    audioSession: environment.audioSession,
                    uuid: environment.uuid
                )
            )
            call.kind.addObserver(self) { [weak self] _, _ in
                self?.engagementKind = EngagementKind(with: call.kind.value)
            }
            let chatViewController = startChat(
                withAction: .none,
                showsCallBubble: true
            )

            let callViewController = startCall(
                call,
                withAction: .engagement(mediaType: mediaType)
            )

            engagement = .call(
                callViewController,
                chatViewController,
                .none,
                call
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

        gliaViewController = makeGliaView(
            bubbleView: bubbleView,
            features: features
        )
        gliaViewController?.insertChild(navigationController)
        event(.maximized)
        delegate?(.started)
    }
}

extension RootCoordinator {
    private func end() {

        let dismissGliaViewController = { [weak self] in
            self?.dismissGliaViewController(animated: true) { [weak self] in
                self?.event(.minimized)
                self?.engagement = .none
                self?.navigationPresenter.setViewControllers([], animated: false)
                self?.removeAllCoordinators()
                self?.engagementKind = .none
                self?.delegate?(.ended)
            }
        }

        let presentSurvey = { [weak self] (engagementId: String, survey: CoreSdkClient.Survey) in
            guard let self = self else { return }
            let viewController = Survey.ViewController(theme: self.viewFactory.theme)
            viewController.props = .live(
                sdkSurvey: survey,
                engagementId: engagementId,
                submitSurveyAnswer: self.environment.submitSurveyAnswer,
                cancel: {
                    viewController.dismiss(animated: true) {
                        dismissGliaViewController()
                    }
                },
                endEditing: { viewController.view.endEditing(true) },
                updateProps: { viewController.props = $0 },
                completion: {
                    viewController.dismiss(animated: true) {
                        dismissGliaViewController()
                    }
                }
            )
            self.gliaViewController?.removeBubbleWindow()
            self.gliaPresenter.present(viewController, animated: true)
        }

        guard let engagement = interactor.currentEngagement else {
            dismissGliaViewController()
            return
        }

        engagement.getSurvey { result in

            guard
                case .success(let survey) = result,
                let survey = survey
            else {
                dismissGliaViewController()
                return
            }

            presentSurvey(engagement.id, survey)
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
            screenShareHandler: screenShareHandler,
            isWindowVisible: isWindowVisible,
            startAction: startAction,
            environment: .init(
                chatStorage: environment.chatStorage,
                fetchFile: environment.fetchFile,
                sendSelectedOptionValue: environment.sendSelectedOptionValue,
                uploadFileToEngagement: environment.uploadFileToEngagement,
                fileManager: environment.fileManager,
                data: environment.data,
                date: environment.date,
                gcd: environment.gcd,
                localFileThumbnailQueue: environment.localFileThumbnailQueue,
                uiImage: environment.uiImage,
                createFileDownload: environment.createFileDownload,
                fromHistory: environment.fromHistory,
                fetchSiteConfigurations: environment.fetchSiteConfigurations,
                getCurrentEngagement: environment.getCurrentEngagement,
                submitSurveyAnswer: environment.submitSurveyAnswer
            )
        )
        coordinator.delegate = { [weak self] event in
            self?.handleChatCoordinatorEvent(event: event)
        }
        pushCoordinator(coordinator)

        return coordinator.start()
    }

    // swiftlint:disable function_body_length
    private func handleChatCoordinatorEvent(event: ChatCoordinator.DelegateEvent) {
        switch event {
        case .back:
            switch engagement {
            case .chat:
                if case .none = interactor.state {
                    popCoordinator()
                    end()
                } else {
                    gliaViewController?.minimize(animated: true)
                }
            case .call(let callViewController, _, let upgradedFrom, _):
                if upgradedFrom == .chat {
                    gliaViewController?.minimize(animated: true)
                } else {
                    navigationPresenter.pop(to: callViewController, animated: true)
                }
            default:
                popCoordinator()
                end()
            }
        case .engaged(let operatorImageUrl):
            gliaViewController?.bubbleKind = .userImage(url: operatorImageUrl)
        case .mediaUpgradeAccepted(let offer, let answer):
            chatMediaUpgradeAccepted(offer: offer, answer: answer)
        case .call:
            switch engagement {
            case .call(let callViewController, _, let upgradedFrom, _):
                switch upgradedFrom {
                case .none:
                    navigationController.popToViewController(callViewController, animated: true)
                case .chat:
                    navigationPresenter.push(callViewController, animated: true)
                }
            default:
                break
            }
        case .finished:
            popCoordinator()
            self.end()
        }
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
            screenShareHandler: screenShareHandler,
            startAction: startAction,
            environment: .init(
                chatStorage: environment.chatStorage,
                fetchFile: environment.fetchFile,
                sendSelectedOptionValue: environment.sendSelectedOptionValue,
                uploadFileToEngagement: environment.uploadFileToEngagement,
                fileManager: environment.fileManager,
                data: environment.data,
                date: environment.date,
                gcd: environment.gcd,
                localFileThumbnailQueue: environment.localFileThumbnailQueue,
                uiImage: environment.uiImage,
                createFileDownload: environment.createFileDownload,
                fromHistory: environment.fromHistory,
                fetchSiteConfigurations: environment.fetchSiteConfigurations,
                getCurrentEngagement: environment.getCurrentEngagement,
                timerProviding: environment.timerProviding,
                submitSurveyAnswer: environment.submitSurveyAnswer
            )
        )
        coordinator.delegate = { [weak self] event in
            guard let self = self else { return }
            switch event {
            case .back:
                switch self.engagement {
                case .call(_, let chatViewController, let upgradedFrom, _):
                    if upgradedFrom == .chat {
                        self.navigationPresenter.pop(to: chatViewController, animated: true)
                    } else {
                        self.gliaViewController?.minimize(animated: true)
                    }
                default:
                    break
                }
            case .engaged(let operatorImageUrl):
                self.gliaViewController?.bubbleKind = .userImage(url: operatorImageUrl)
            case .chat:
                switch self.engagement {
                case .call(_, let chatViewController, let upgradedFrom, _):
                    if upgradedFrom == .chat {
                        self.navigationPresenter.pop(to: chatViewController, animated: true)
                    } else {
                        self.navigationPresenter.push(chatViewController, animated: true)
                    }
                default:
                    break
                }
            case .minimize:
                self.gliaViewController?.minimize(animated: true)
            case .finished:
                self.popCoordinator()
                self.end()
            case .visitorOnHoldUpdated(let isOnHold):
                self.gliaViewController?.setVisitorHoldState(isOnHold: isOnHold)
            }
        }
        pushCoordinator(coordinator)

        return coordinator.start()
    }
    // swiftlint:enable function_body_length

    private func makeGliaView(
        bubbleView: BubbleView,
        features: Features
    ) -> GliaViewController {
        if #available(iOS 13.0, *) {
            if let sceneProvider = sceneProvider {
                return GliaViewController(
                    bubbleView: bubbleView,
                    delegate: self,
                    sceneProvider: sceneProvider,
                    features: features
                )
            } else {
                return GliaViewController(
                    bubbleView: bubbleView,
                    delegate: self,
                    features: features
                )
            }
        } else {
            return GliaViewController(
                bubbleView: bubbleView,
                delegate: self,
                features: features
            )
        }
    }
}

extension RootCoordinator {
    private func presentGliaViewController(animated: Bool, completion: (() -> Void)? = nil) {
        guard let gliaViewController = gliaViewController else { return }
        gliaPresenter.present(gliaViewController, animated: animated) { [weak self] in
            self?.isWindowVisible.value = true
            completion?()
        }
    }

    private func dismissGliaViewController(animated: Bool, completion: (() -> Void)? = nil) {
        guard let gliaViewController = gliaViewController else { return }
        gliaPresenter.dismiss(gliaViewController, animated: animated) { [weak self] in
            self?.isWindowVisible.value = false
            completion?()
        }
    }
}

extension RootCoordinator {
    private func chatMediaUpgradeAccepted(
        offer: CoreSdkClient.MediaUpgradeOffer,
        answer: @escaping CoreSdkClient.AnswerWithSuccessBlock
    ) {
        switch engagement {
        case .chat(let chatViewController):
            guard let kind = CallKind(with: offer) else { return }
            let call = Call(
                kind,
                environment: .init(
                    audioSession: environment.audioSession,
                    uuid: environment.uuid
                )
            )
            call.kind.addObserver(self) { [weak self] _, _ in
                self?.engagementKind = EngagementKind(with: call.kind.value)
            }
            let callViewController = startCall(call, withAction: .call(offer: offer, answer: answer))
            engagement = .call(
                callViewController,
                chatViewController,
                .chat,
                call
            )
            chatCall.value = call
            navigationPresenter.push(callViewController)

        case .call(_, _, _, let call):
            call.upgrade(to: offer)
            navigationPresenter.pop()
            answer(true, nil)

        case .none:
            break
        }
    }
}

extension RootCoordinator: GliaViewControllerDelegate {
    func event(_ event: GliaViewControllerEvent) {
        switch event {
        case .minimized:
            dismissGliaViewController(animated: true) { [weak self] in
                self?.isWindowVisible.value = false
                self?.delegate?(.minimized)
            }
        case .maximized:
            presentGliaViewController(animated: true) { [weak self] in
                self?.isWindowVisible.value = true
                self?.delegate?(.maximized)
            }
        }
    }
}

extension RootCoordinator {

    func maximize() {
        gliaViewController?.maximize(animated: true)
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

extension RootCoordinator {
    struct Environment {
        var chatStorage: Glia.Environment.ChatStorage
        var fetchFile: CoreSdkClient.FetchFile
        var sendSelectedOptionValue: CoreSdkClient.SendSelectedOptionValue
        var uploadFileToEngagement: CoreSdkClient.UploadFileToEngagement
        var audioSession: Glia.Environment.AudioSession
        var uuid: () -> UUID
        var fileManager: FoundationBased.FileManager
        var data: FoundationBased.Data
        var date: () -> Date
        var gcd: GCD
        var localFileThumbnailQueue: FoundationBased.OperationQueue
        var uiImage: UIKitBased.UIImage
        var createFileDownload: FileDownloader.CreateFileDownload
        var fromHistory: () -> Bool
        var timerProviding: FoundationBased.Timer.Providing
        var fetchSiteConfigurations: CoreSdkClient.FetchSiteConfigurations
        var getCurrentEngagement: CoreSdkClient.GetCurrentEngagement
        var submitSurveyAnswer: CoreSdkClient.SubmitSurveyAnswer
    }
}

extension RootCoordinator {
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
        case call(CallViewController, ChatViewController, UpgradedFrom, Call)
    }

    private enum UpgradedFrom {
        case none
        case chat
    }
}
