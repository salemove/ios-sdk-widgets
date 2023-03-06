#if DEBUG

import Foundation

extension Configuration {

    static func mock(
        authMethod: AuthorizationMethod = .siteApiKey(id: "site-api-key-id", secret: "site-api-key-secret"),
        environment: Environment = .beta,
        site: String = "site-id"
    ) -> Self {
        Configuration(
            authorizationMethod: authMethod,
            environment: environment,
            site: site
        )
    }
}

#endif
