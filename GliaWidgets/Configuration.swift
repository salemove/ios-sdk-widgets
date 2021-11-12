/// Glia's environment. Use the one that our account manager has assigned to you.
public enum Environment {
    /// Europe
    case europe
    /// USA
    case usa
    /// Beta environment. For development use.
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

/// Glia's engagement configuration.
public struct Configuration {
    /// Application token
    public let appToken: String
    /// Deprecated.
    /// The current provided api token
    @available(*, deprecated, message: "Api token is not supported.")
    public let apiToken: String = ""
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
        self.appToken = appToken
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
    public init(
        appToken: String,
        environment: Environment,
        site: String
    ) {
        self.appToken = appToken
        self.environment = environment
        self.site = site
    }
}
