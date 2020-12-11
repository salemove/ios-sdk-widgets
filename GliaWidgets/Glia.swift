import UIKit
import SalemoveSDK

public enum EngagementKind {
    case chat
    case audioCall
    case videoCall
}

public class Glia {
    private var rootCoordinator: RootCoordinator?
    private let conf: Configuration
    private let appDelegate = SalemoveAppDelegate()

    public init(conf: Configuration) {
        self.conf = conf
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
                                          engagementKind: engagementKind)
        rootCoordinator?.start()
    }
}
