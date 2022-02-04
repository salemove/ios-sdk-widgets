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
            return .custom(URL(string: "https://api.beta.salemove.com/")!)
        }
    }
}

/// Glia's engagement configuration.
public struct Configuration {
    /// Application token
    @available(*, deprecated, message: "Use `authorizationMethod` instead.")
    public var appToken: String {
        if case .appToken(let value) = authorizationMethod {
            return value
        } else {
            return ""
        }
    }
    /// Deprecated.
    /// The current provided api token
    @available(*, deprecated, message: "Api token is not supported.")
    public let apiToken: String = ""
    /// Site authorization method
    public let authorizationMethod: AuthorizationMethod
    /// Environment
    public let environment: Environment
    /// Site
    public let site: String

    /// Initializes the configuration.
    ///
    /// - Parameters:
    ///   - appToken: The application token.
    ///   - apiToken: The API token.
    ///   - environment: The environment to use.
    ///   - site: The site to use.
    ///
    @available(*, deprecated, message: "Deprecated. Please use Configuration(appToken:environment:site:) instead")
    public init(
        appToken: String,
        apiToken: String,
        environment: Environment,
        site: String
    ) {
        self.authorizationMethod = .appToken(appToken)
        self.environment = environment
        self.site = site
    }

    /// Initializes the configuration.
    ///
    /// - Parameters:
    ///   - appToken: The application token.
    ///   - environment: The environment to use.
    ///   - site: The site to use.
    ///
    @available(*, deprecated, message: "Deprecated. Please use Configuration(authorizationMethod:environment:site:) instead")
    public init(
        appToken: String,
        environment: Environment,
        site: String
    ) {
        self.authorizationMethod = .appToken(appToken)
        self.environment = environment
        self.site = site
    }

    /// Initializes the configuration.
    ///
    /// - Parameters:
    ///   - authorizationMethod: The site authorization method.
    ///   - environment: The environment to use.
    ///   - site: The site to use.
    ///
    public init(
        authorizationMethod: AuthorizationMethod,
        environment: Environment,
        site: String
    ) {
        self.authorizationMethod = authorizationMethod
        self.environment = environment
        self.site = site
    }
}

public extension Configuration {
    /// Site authorization method
    enum AuthorizationMethod {
        @available(*, deprecated, message: "Use `siteApiKey` authorization instead.")
        case appToken(String)
        /// Site API key authorization
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
