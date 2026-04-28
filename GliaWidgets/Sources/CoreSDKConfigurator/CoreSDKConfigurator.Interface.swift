import Foundation

struct CoreSDKConfigurator {
    var configureWithInteractor: CoreSdkClient.ConfigureWithInteractor
    var configureWithConfiguration: (Configuration) async throws -> Void
}

extension CoreSDKConfigurator {
    static func create(coreSdk: CoreSdkClient) -> Self {
        .init(
            configureWithInteractor: coreSdk.configureWithInteractor,
            configureWithConfiguration: { configuration in
                let sdkConfiguration = try CoreSdkClient.Configuration(
                    siteId: configuration.site,
                    region: configuration.environment.region,
                    authorizingMethod: configuration.authorizationMethod.coreAuthorizationMethod,
                    pushNotifications: configuration.pushNotifications.coreSdk,
                    manualLocaleOverride: configuration.manualLocaleOverride,
                    suppressPushNotificationsPermissionRequestDuringAuthentication: configuration
                        .suppressPushNotificationsPermissionRequestDuringAuthentication,
                    isPushNotificationProxyEnabled: configuration.isPushNotificationProxyEnabled
                )
                try await coreSdk.configureWithConfiguration(sdkConfiguration)
            }
        )
    }
}
