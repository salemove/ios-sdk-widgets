import UIKit

public enum Environment {
    case europe
    case usa
    case beta

    var url: String {
        switch self {
        case .europe:
            return "https://api.salemove.eu"
        case .usa:
            return "https://api.salemove.com"
        case .beta:
            return "https://api.beta.salemove.com/"
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

public class Glia {
    private let configuration: Configuration
    private var rootCoordinator: RootCoordinator?

    public init(conf: Configuration) {
        self.configuration = conf
        configure()
    }

    public func start(_ engagementKind: EngagementKind,
                      queueID: String,
                      using theme: Theme = Theme()) {
        let viewFactory = ViewFactory(with: theme)
        rootCoordinator = RootCoordinator(viewFactory: viewFactory,
                                          engagementKind: engagementKind)
        rootCoordinator?.start()
    }

    private func configure() {}
}
