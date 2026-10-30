#if DEBUG

import Foundation

extension Configuration {
    static func mock(
        environment: Environment = .beta,
        site: String = "site-id",
        companyName: String = "",
        manualLocaleOverride: String? = nil,
        suppressPushNotificationsPermissionRequestDuringAuthentication: Bool = false
    ) -> Self {
        Configuration(
            environment: environment,
            site: site,
            companyName: companyName,
            manualLocaleOverride: manualLocaleOverride,
            suppressPushNotificationsPermissionRequestDuringAuthentication: suppressPushNotificationsPermissionRequestDuringAuthentication
        )
    }
}

#endif
