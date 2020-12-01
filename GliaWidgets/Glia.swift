import UIKit

public enum Environment {
    case europe
    case usa

    var url: String {
        switch self {
        case .europe:
            return "https://api.salemove.eu"
        case .usa:
            return "https://api.salemove.com"
        }
    }
}

public struct Configuration {
    public let appToken: String
    public let apiToken: String
    public let environment: Environment
    public let site: String

    public init(appToken: String,
                apiToken: String,
                environment: Environment,
                site: String) {
        self.appToken = appToken
        self.apiToken = apiToken
        self.environment = environment
        self.site = site
    }
}

public enum EngagementKind {
    case chat
    case audioCall
    case videoCall
}

enum PresentationKind {
    case push(UINavigationController)
    case present(UIViewController)

    init(with viewController: UIViewController) {
        if let navigationController = viewController as? UINavigationController {
            self = .push(navigationController)
        } else {
            self = .present(viewController)
        }
    }
}

public class Glia {
    private let configuration: Configuration
    private var rootCoordinator: RootCoordinator?

    public init(conf: Configuration) {
        self.configuration = conf
        configure()
    }

    public func start(_ engagementKind: EngagementKind,
                      from viewController: UIViewController,
                      using theme: Theme = Theme()) {
        let viewFactory = ViewFactory(with: theme)
        let presentationKind = PresentationKind(with: viewController)
        rootCoordinator = RootCoordinator(viewFactory: viewFactory,
                                          engagementKind: engagementKind,
                                          presentationKind: presentationKind)
        rootCoordinator?.start()
    }

    private func configure() {}
}
