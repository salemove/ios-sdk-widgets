import UIKit
import SalemoveSDK

public enum EngagementKind {
    case chat
    case audioCall
    case videoCall
}

public enum GliaEvent {
    case started
    case ended
    case minimized
    case maximized
}

public protocol SceneProvider: class {
    @available(iOS 13.0, *)
    func windowScene() -> UIWindowScene?
}

public class Glia {
    public var onEvent: ((GliaEvent) -> Void)?

    private var rootCoordinator: RootCoordinator?
    private let conf: Configuration
    private weak var sceneProvider: SceneProvider?
    private let appDelegate = SalemoveAppDelegate()

    public init(
        configuration: Configuration,
        sceneProvider: SceneProvider? = nil) {
        self.conf = configuration
        self.sceneProvider = sceneProvider
    }

    public func start(_ engagementKind: EngagementKind,
                      queueID: String,
                      visitorContext: VisitorContext,
                      using theme: Theme = Theme()) throws {
        let interactor = try Interactor(
            with: conf,
            queueID: queueID,
            visitorContext: visitorContext
        )
        let viewFactory = ViewFactory(with: theme)
        startRootCoordinator(with: interactor,
                             viewFactory: viewFactory,
                             engagementKind: engagementKind)
    }

    private func startRootCoordinator(with interactor: Interactor,
                                      viewFactory: ViewFactory,
                                      engagementKind: EngagementKind) {
        rootCoordinator = RootCoordinator(
            interactor: interactor,
            viewFactory: viewFactory,
            sceneProvider: sceneProvider,
            engagementKind: engagementKind
        )
        rootCoordinator?.delegate = { [weak self] event in
            switch event {
            case .started:
                self?.onEvent?(.started)
            case .ended:
                self?.rootCoordinator = nil
                self?.onEvent?(.ended)
            case .minimized:
                self?.onEvent?(.minimized)
            case .maximized:
                self?.onEvent?(.maximized)
            }
        }
        rootCoordinator?.start()
    }
}
