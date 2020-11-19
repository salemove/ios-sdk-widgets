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
    public let applicationToken: String
    public let apiToken: String
    public let environment: Environment
    public let site: String

    public init(applicationToken: String,
                apiToken: String,
                environment: Environment,
                site: String) {
        self.applicationToken = applicationToken
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

public enum PresentationKind {
    case pushTo(UINavigationController)
    case presentFrom(UIViewController)
}

public class Glia {
    public let configuration: Configuration

    private var rootCoordinator: RootCoordinator?

    public init(configuration: Configuration) {
        self.configuration = configuration
        configure()
    }

    public func start(_ engagementKind: EngagementKind,
                      presentation presentationKind: PresentationKind,
                      theme: Theme = DefaultTheme()) {
        let viewFactory = ViewFactory(with: theme)
        rootCoordinator = RootCoordinator(viewFactory: viewFactory,
                                          engagementKind: engagementKind,
                                          presentationKind: presentationKind)
        rootCoordinator?.start()
    }

    private func configure() {}
}
