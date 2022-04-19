import UIKit

final class EngagementCoordinator: UIViewControllerCoordinator {
    enum DelegateEvent {
        case minimize
        case engaged(operatorImageUrl: String?)
        case started
        case ended
        case engagementChanged(EngagementKind)
        case unreadMessagesCount(Int)
    }

    var delegate: ((DelegateEvent) -> Void)?
    var engagementKind: EngagementKind {
        didSet {
            delegate?(.engagementChanged(engagementKind))
        }
    }

    private let unreadMessages = ObservableValue<Int>(with: 0)
    private let screenShareHandler = ScreenShareHandler()

    private weak var presenter: UINavigationController?

    private let interactor: Interactor
    private let isWindowVisible: ObservableValue<Bool>
    private let viewFactory: ViewFactory
    private let environment: Environment

    init(
        interactor: Interactor,
        engagementKind: EngagementKind,
        isWindowVisible: ObservableValue<Bool>,
        viewFactory: ViewFactory,
        environment: Environment
    ) {
        self.interactor = interactor
        self.engagementKind = engagementKind
        self.isWindowVisible = isWindowVisible
        self.viewFactory = viewFactory
        self.environment = environment

        super.init(
            environment: .init(
                uuid: environment.uuid
            )
        )

        setup()
    }

    override func start() -> UIViewController {
        defer {
            delegate?(.started)
        }

        let rootViewController = createRoot()
        let navigationController = EngagementNavigationController(
            rootViewController: rootViewController
        )

        navigationController.setNavigationBarHidden(true, animated: false)

        self.presenter = navigationController

        return navigationController
    }

    private func setup() {
        unreadMessages.addObserver(self, update: { [weak self] itemCount, _ in
            self?.delegate?(.unreadMessagesCount(itemCount))
        })
    }

    private func createRoot() -> UIViewController {
        switch engagementKind {
        case .none:
            assertionFailure("engagementKind cannot be none")
            return UIViewController()

        case .chat:
            return createChat(
                withAction: .startEngagement,
                showsCallBubble: false
            )

        case .audioCall:
            return createCall(
                callKind: .audio,
                withAction: .engagement(mediaType: .audio)
            )

        case .videoCall:
            return createCall(
                callKind: .video(direction: .oneWay),
                withAction: .engagement(mediaType: .video)
            )
        }
    }

    private func createCall(
        callKind: CallKind,
        withAction startAction: CallViewModel.StartAction
    ) -> UIViewController {
        let call = Call(
            callKind,
            environment: .init(
                audioSession: environment.audioSession,
                uuid: environment.uuid
            )
        )

        let coordinator = CallCoordinator(
            interactor: interactor,
            viewFactory: viewFactory,
            call: call,
            unreadMessages: unreadMessages,
            screenShareHandler: screenShareHandler,
            startAction: startAction,
            environment: .init(
                timerProviding: environment.timerProviding,
                date: environment.date,
                uuid: environment.uuid
            )
        )

        coordinator.delegate = { [weak self] event in
            switch event {
            case .back:
                self?.delegate?(.minimize)

            case .engaged(operatorImageUrl: let operatorImageUrl):
                self?.delegate?(.engaged(operatorImageUrl: operatorImageUrl))

            case .mediaUpgradeAccepted(offer: let offer, answer: let answer):
                guard
                    let self = self,
                    let callKind = CallKind(with: offer)
                else { return }

                let call = self.createCall(
                    callKind: callKind,
                    withAction: .call(offer: offer, answer: answer)
                )

                self.presenter?.setViewControllers([call], animated: true)

            case .chat:
                guard let self = self else { return }

                let startAction: ChatViewModel.StartAction = self.engagementKind == .chat
                    ? .none(call: call)
                    : .none(call: nil)

                let chat = self.createChat(
                    withAction: startAction,
                    showsCallBubble: true
                )

                self.presenter?.pushViewController(chat, animated: true)

            case .minimize:
                self?.delegate?(.minimize)

            case .finished:
                self?.delegate?(.ended)
            }
        }

        return coordinate(to: coordinator)
    }

    private func createChat(
        withAction startAction: ChatViewModel.StartAction,
        showsCallBubble: Bool
    ) -> UIViewController {
        let coordinator = ChatCoordinator(
            interactor: interactor,
            viewFactory: viewFactory,
            unreadMessages: unreadMessages,
            isWindowVisible: isWindowVisible,
            showsCallBubble: showsCallBubble,
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
                uuid: environment.uuid
            )
        )

        coordinator.delegate = { [weak self] event in
            switch event {
            case .back:
                if case .none? = self?.interactor.state {
                    self?.delegate?(.ended)
                } else if self?.presenter?.viewControllers.count == 1 {
                    self?.delegate?(.minimize)
                } else {
                    self?.presenter?.popViewController(animated: true)
                }

            case .engaged(operatorImageUrl: let operatorImageUrl):
                self?.delegate?(.engaged(operatorImageUrl: operatorImageUrl))

            case .mediaUpgradeAccepted(offer: let offer, answer: let answer):
                guard
                    let self = self,
                    let callKind = CallKind(with: offer)
                else { return }

                let call = self.createCall(
                    callKind: callKind,
                    withAction: .call(offer: offer, answer: answer)
                )

                self.presenter?.setViewControllers([call], animated: true)

            case .call:
                self?.presenter?.popViewController(animated: true)

            case .finished:
                self?.delegate?(.ended)
            }
        }

        return coordinate(to: coordinator)
    }

    deinit {
        unreadMessages.removeObserver(self)
    }
}

extension EngagementCoordinator {
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
        var timerProviding: FoundationBased.Timer.Providing
        var gcd: GCD
        var localFileThumbnailQueue: FoundationBased.OperationQueue
        var uiImage: UIKitBased.UIImage
        var createFileDownload: FileDownloader.CreateFileDownload
        var fromHistory: () -> Bool
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
