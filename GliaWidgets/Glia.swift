import UIKit

public enum EngagementKind {
    case chat
    case audioCall
    case videoCall
}

public class Glia {
    private var rootCoordinator: RootCoordinator?
    private let interactor: Interactor

    public init(conf: Configuration) throws {
        self.interactor = try Interactor(with: conf)
    }

    public func start(_ engagementKind: EngagementKind,
                      queueID: String,
                      using theme: Theme = Theme()) {
        let viewFactory = ViewFactory(with: theme)
        rootCoordinator = RootCoordinator(viewFactory: viewFactory,
                                          engagementKind: engagementKind)
        rootCoordinator?.start()
    }
}
