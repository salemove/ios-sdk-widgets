import Foundation

struct CoreSDKConfigurator {
    var configureWithInteractor: CoreSdkClient.ConfigureWithInteractor
    var configureWithConfiguration: (Configuration, (() -> Void)?) throws -> Void
}

extension CoreSDKConfigurator {
    static func create(coreSdk: CoreSdkClient) -> Self {
        .init(
            configureWithInteractor: coreSdk.configureWithInteractor,
            configureWithConfiguration: { configuration, completion in
                let sdkConfiguration = try CoreSdkClient.Salemove.Configuration(
                    siteId: configuration.site,
                    region: configuration.environment.region,
                    authorizingMethod: configuration.authorizationMethod.coreAuthorizationMethod,
                    pushNotifications: configuration.pushNotifications.coreSdk
                )
                coreSdk.configureWithConfiguration(sdkConfiguration) {
                    completion?()
                }
            }
        )
    }
}
