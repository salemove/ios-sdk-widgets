import Foundation

/// Glia's environment. Use the one that our account manager has assigned to you.
public enum Environment {
    /// Europe
    case europe
    /// USA
    case usa
    /// Beta environment. For development use.
    case beta

    var region: CoreSdkClient.Salemove.Region {
        switch self {
        case .usa:
            return .us
        case .europe:
            return .eu
        case .beta:
            // swiftlint:disable force_unwrapping
            return .custom(URL(string: "https://api.beta.salemove.com/")!)
            // swiftlint:enable force_unwrapping
        }
    }
}

/// Glia's engagement configuration.
public struct Configuration {
    /// Site authorization method
    public let authorizationMethod: AuthorizationMethod
    /// Environment
    public let environment: Environment
    /// Site
    public let site: String
    /// Visitor Context
    public let visitorContext: VisitorContext?

    /// Initializes the configuration.
    ///
    /// - Parameters:
    ///   - authorizationMethod: The site authorization method.
    ///   - environment: The environment to use.
    ///   - site: The site to use.
    ///   - visitorContext: Additional context about the visitor that operator may need.
    ///
    public init(
        authorizationMethod: AuthorizationMethod,
        environment: Environment,
        site: String,
        visitorContext: VisitorContext? = nil
    ) {
        self.authorizationMethod = authorizationMethod
        self.environment = environment
        self.site = site
        self.visitorContext = visitorContext
    }
}

public extension Configuration {
    /// Site authorization method.
    enum AuthorizationMethod {
        @available(*, deprecated, message: "Use `siteApiKey` authorization instead.")
        case appToken(String)
        /// Site API key authorization.
        case siteApiKey(id: String, secret: String)

        var coreAuthorizationMethod: CoreSdkClient.Salemove.AuthorizationMethod {
            switch self {
            case .siteApiKey(let id, let secret):
                return .siteApiKey(id: id, secret: secret)
            case .appToken(let token):
                return .appToken(token)
            }
        }
    }
}

extension Configuration {
    /// Additional context about the visitor that operator may need.
    public struct VisitorContext {
        /// Asset ID represented by UUID from Glia Hub.
        public let assetId: UUID

        ///
        /// - Parameter assetId: Asset ID represented by UUID from Glia Hub.
        public init(assetId: UUID) {
            self.assetId = assetId
        }
    }
}
