import UIKit

final class RootCoordinator: UIViewControllerCoordinator {
    enum DelegateEvent {
        case started
        case engagementChanged(EngagementKind)
        case ended
        case minimized
        case maximized
    }

    var delegate: ((DelegateEvent) -> Void)?

    var engagementKind: EngagementKind {
        didSet {
            delegate?(.engagementChanged(engagementKind))
        }
    }

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

    private let interactor: Interactor
    private let viewFactory: ViewFactory
    private let features: Features
    private let environment: Environment
    private let isWindowVisible = ObservableValue<Bool>(with: false)

    private var gliaViewController: GliaViewController?
    private weak var sceneProvider: SceneProvider?

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
        self.engagementKind = engagementKind
        self.features = features
        self.environment = environment

        super.init(
            environment: .init(
                uuid: environment.uuid
            )
        )
    }

    @discardableResult
    override func start() -> UIViewController {
        let viewController = createGliaViewController()
        self.gliaViewController = viewController

        presentEngagement()

        return viewController
    }

    private func presentEngagement() {
        let coordinator = EngagementCoordinator(
            interactor: interactor,
            engagementKind: engagementKind,
            isWindowVisible: isWindowVisible,
            viewFactory: viewFactory,
            environment: .init(
                chatStorage: environment.chatStorage,
                fetchFile: environment.fetchFile,
                sendSelectedOptionValue: environment.sendSelectedOptionValue,
                uploadFileToEngagement: environment.uploadFileToEngagement,
                audioSession: environment.audioSession,
                uuid: environment.uuid,
                fileManager: environment.fileManager,
                data: environment.data,
                date: environment.date,
                timerProviding: environment.timerProviding,
                gcd: environment.gcd,
                localFileThumbnailQueue: environment.localFileThumbnailQueue,
                uiImage: environment.uiImage,
                createFileDownload: environment.createFileDownload,
                fromHistory: environment.fromHistory
            )
        )

        let viewController = coordinate(to: coordinator)

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

            case .unreadMessagesCount(let itemCount):
                self?.gliaViewController?.setBubbleBadge(itemCount: itemCount)
            }
        }

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

extension RootCoordinator: GliaViewControllerDelegate {
    func event(_ event: GliaViewControllerEvent) {
        switch event {
        case .minimized:
            gliaViewController?.presentingViewController?.dismiss(
                animated: true,
                completion: { [weak self] in
                    self?.isWindowVisible.value = false
                    self?.delegate?(.minimized)
                }
            )

        case .maximized:
            guard let gliaViewController = gliaViewController else { return }

            presenter.present(
                gliaViewController,
                animated: true,
                completion: { [weak self] in
                    self?.isWindowVisible.value = true
                    self?.delegate?(.maximized)
                }
            )
        }
    }
}

extension RootCoordinator {
    func maximize() {
        gliaViewController?.maximize(animated: true)
    }
}

extension RootCoordinator {
    func end() {
        gliaViewController?.presentingViewController?.dismiss(
            animated: true,
            completion: { [weak self] in
                self?.delegate?(.ended)
                self?.engagementKind = .none
                self?.isWindowVisible.value = false
            }
        )
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
    }
}
