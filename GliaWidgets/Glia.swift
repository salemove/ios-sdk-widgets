import UIKit
import SalemoveSDK

public enum EngagementKind {
    case none
    case chat
    case audioCall
    case videoCall
}

public enum GliaEvent {
    case started
    case engagementChanged(EngagementKind)
    case ended
    case minimized
    case maximized
}

public protocol SceneProvider: class {
    @available(iOS 13.0, *)
    func windowScene() -> UIWindowScene?
}

public class Glia {
    public static let shared = Glia()
    public var engagement: EngagementKind { return rootCoordinator?.engagementKind ?? .none }
    public var onEvent: ((GliaEvent) -> Void)?

    private var rootCoordinator: RootCoordinator?

    private init() {}

    public func start(
        _ engagementKind: EngagementKind,
        configuration: Configuration,
        queueID: String,
        visitorContext: VisitorContext,
        theme: Theme = Theme(),
        sceneProvider: SceneProvider? = nil
    ) throws {
        guard engagement == .none else {
            print("Warning: trying to start new Glia session while session is already active.")
            return
        }
        let interactor = try Interactor(
            with: configuration,
            queueID: queueID,
            visitorContext: visitorContext
        )
        let viewFactory = ViewFactory(with: theme)
        startRootCoordinator(
            with: interactor,
            viewFactory: viewFactory,
            sceneProvider: sceneProvider,
            engagementKind: engagementKind
        )
    }

    private func startRootCoordinator(
        with interactor: Interactor,
        viewFactory: ViewFactory,
        sceneProvider: SceneProvider?,
        engagementKind: EngagementKind
    ) {
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
            case .engagementChanged(let engagementKind):
                self?.onEvent?(.engagementChanged(engagementKind))
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
