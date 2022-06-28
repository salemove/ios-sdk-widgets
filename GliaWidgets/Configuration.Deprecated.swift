import Foundation

extension Configuration {
    /// Deprecated.
    @available(*, deprecated, message: "Use `authorizationMethod` instead.")
    public var appToken: String {
        if case .appToken(let value) = authorizationMethod {
            return value
        } else {
            return ""
        }
    }

    /// Deprecated.
    @available(*, deprecated, message: "Api token is not supported.")
    public var apiToken: String { "" }

    /// Deprecated.
    @available(*, deprecated, message: "Use Configuration(authorizationMethod:environment:site:visitorContext:) instead.")
    public init(
        appToken: String,
        apiToken: String,
        environment: Environment,
        site: String
    ) {
        self.init(
            authorizationMethod: .appToken(appToken),
            environment: environment,
            site: site,
            visitorContext: nil
        )
    }

    /// Deprecated.
    @available(*, deprecated, message: "Use Configuration(authorizationMethod:environment:site:visitorContext:) instead.")
    public init(
        appToken: String,
        environment: Environment,
        site: String
    ) {
        self.init(
            authorizationMethod: .appToken(appToken),
            environment: environment,
            site: site,
            visitorContext: nil
        )
    }

    /// Deprecated.
    @available(*, deprecated, message: "Use Configuration(authorizationMethod:environment:site:visitorContext:) instead.")
    public init(
        authorizationMethod: AuthorizationMethod,
        environment: Environment,
        site: String
    ) {
        self.init(
            authorizationMethod: authorizationMethod,
            environment: environment,
            site: site,
            visitorContext: nil
        )
    }
}
