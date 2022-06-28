import Foundation

extension Configuration {
    /// Unavailable.
    @available(*, unavailable, message: "Use `authorizationMethod` instead.")
    public var appToken: String {
        unavailable()
    }

    /// Unavailable.
    @available(*, unavailable, message: "Api token is not supported.")
    public var apiToken: String {
        unavailable()
    }

    /// Unavailable.
    @available(*, unavailable, message: "Use Configuration(authorizationMethod:environment:site:visitorContext:) instead.")
    public init(
        appToken: String,
        apiToken: String,
        environment: Environment,
        site: String
    ) {
        unavailable()
    }

    /// Unavailable.
    @available(*, unavailable, message: "Use Configuration(authorizationMethod:environment:site:visitorContext:) instead.")
    public init(
        appToken: String,
        environment: Environment,
        site: String
    ) {
        unavailable()
    }

    /// Unavailable.
    @available(*, unavailable, message: "Use Configuration(authorizationMethod:environment:site:visitorContext:) instead.")
    public init(
        authorizationMethod: AuthorizationMethod,
        environment: Environment,
        site: String
    ) {
        unavailable()
    }
}
