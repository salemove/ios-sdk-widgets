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

public protocol GliaDelegate: class {
    func event(_ event: GliaEvent)
}

public class Glia {
    private var rootCoordinator: RootCoordinator?
    private let conf: Configuration
    private weak var delegate: GliaDelegate?
    private weak var sceneProvider: SceneProvider?
    private let appDelegate = SalemoveAppDelegate()

    public init(
        configuration: Configuration,
        delegate: GliaDelegate? = nil,
        sceneProvider: SceneProvider? = nil) {
        self.conf = configuration
        self.delegate = delegate
        self.sceneProvider = sceneProvider
    }

    public func start(_ engagementKind: EngagementKind,
                      queueID: String,
                      visitorContext: VisitorContext,
                      using theme: Theme = Theme()) throws {
        let interactor = try Interactor(with: conf,
                                        queueID: queueID,
                                        visitorContext: visitorContext)
        let viewFactory = ViewFactory(with: theme)
        rootCoordinator = RootCoordinator(interactor: interactor,
                                          viewFactory: viewFactory,
                                          gliaDelegate: delegate,
                                          sceneProvider: sceneProvider,
                                          engagementKind: engagementKind)
        rootCoordinator?.start()
    }
}
