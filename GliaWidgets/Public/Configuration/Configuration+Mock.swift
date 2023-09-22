#if DEBUG

import Foundation

extension Configuration {

    static func mock(
        authMethod: AuthorizationMethod = .siteApiKey(id: "site-api-key-id", secret: "site-api-key-secret"),
        environment: Environment = .beta,
        site: String = "site-id",
        companyName: String = ""
    ) -> Self {
        Configuration(
            authorizationMethod: authMethod,
            environment: environment,
            site: site,
            companyName: companyName
        )
    }
}

#endif
