import Foundation
import GliaWidgets

struct ConfigurationDeeplinkHandler: DeeplinkHandler {
    private enum AuthorizationCredentialsDefaultsKey {
        static let siteApiKeyId = "siteApiKeyId"
        static let siteApiKeySecret = "siteApiKeySecret"
        static let userApiKeyId = "userApiKeyId"
        static let userApiKeySecret = "userApiKeySecret"
    }

    private enum AuthorizationConfigurationDefaultsKey {
        static let siteApiKeySite = "siteApiKeySite"
        static let siteApiKeyCompanyName = "siteApiKeyCompanyName"
        static let siteApiKeyQueueId = "siteApiKeyQueueId"
        static let siteApiKeyUseDefaultQueue = "siteApiKeyUseDefaultQueue"
        static let userApiKeySite = "userApiKeySite"
        static let userApiKeyCompanyName = "userApiKeyCompanyName"
        static let userApiKeyQueueId = "userApiKeyQueueId"
        static let userApiKeyUseDefaultQueue = "userApiKeyUseDefaultQueue"
    }

    private let context: DeeplinkContext

    init(context: DeeplinkContext) {
        self.context = context
    }

    @MainActor
    func handleDeeplink(
        with path: String?,
        queryItems: [URLQueryItem]?
    ) -> Bool {
        guard let queryItems,
              let configuration = Configuration(queryItems: queryItems) else {
            return false
        }

        let queueId = queryItems.first(where: { $0.name == "queue_id" })?.value
        let useDefaultQueue = (queueId?.isEmpty ?? true)

        storeAuthorizationCredentials(for: configuration.authorizationMethod)
        storeAuthorizationConfiguration(
            for: configuration.authorizationMethod,
            site: configuration.site,
            companyName: configuration.companyName,
            queueId: queueId ?? "",
            useDefaultQueue: useDefaultQueue
        )

        context.appState.configuration = configuration
        context.appState.queueId = queueId ?? ""
        context.appState.useDefaultQueue = useDefaultQueue

        context.appState.saveConfiguration()
        return true
    }

    private func configurationStorageKeys(
        for authorizationMethod: Configuration.AuthorizationMethod
    ) -> (site: String, companyName: String, queueId: String, useDefaultQueue: String)? {
        switch authorizationMethod {
        case .siteApiKey:
            return (
                AuthorizationConfigurationDefaultsKey.siteApiKeySite,
                AuthorizationConfigurationDefaultsKey.siteApiKeyCompanyName,
                AuthorizationConfigurationDefaultsKey.siteApiKeyQueueId,
                AuthorizationConfigurationDefaultsKey.siteApiKeyUseDefaultQueue
            )
        case .userApiKey:
            return (
                AuthorizationConfigurationDefaultsKey.userApiKeySite,
                AuthorizationConfigurationDefaultsKey.userApiKeyCompanyName,
                AuthorizationConfigurationDefaultsKey.userApiKeyQueueId,
                AuthorizationConfigurationDefaultsKey.userApiKeyUseDefaultQueue
            )
        @unknown default:
            return nil
        }
    }

    private func storeAuthorizationConfiguration(
        for authorizationMethod: Configuration.AuthorizationMethod,
        site: String,
        companyName: String,
        queueId: String,
        useDefaultQueue: Bool
    ) {
        guard let keys = configurationStorageKeys(for: authorizationMethod) else { return }
        UserDefaults.standard.set(site, forKey: keys.site)
        UserDefaults.standard.set(companyName, forKey: keys.companyName)
        UserDefaults.standard.set(queueId, forKey: keys.queueId)
        UserDefaults.standard.set(useDefaultQueue, forKey: keys.useDefaultQueue)
    }

    private func storeAuthorizationCredentials(
        for authorizationMethod: Configuration.AuthorizationMethod
    ) {
        switch authorizationMethod {
        case let .siteApiKey(id, secret):
            UserDefaults.standard.set(id, forKey: AuthorizationCredentialsDefaultsKey.siteApiKeyId)
            UserDefaults.standard.set(secret, forKey: AuthorizationCredentialsDefaultsKey.siteApiKeySecret)
        case let .userApiKey(id, secret):
            UserDefaults.standard.set(id, forKey: AuthorizationCredentialsDefaultsKey.userApiKeyId)
            UserDefaults.standard.set(secret, forKey: AuthorizationCredentialsDefaultsKey.userApiKeySecret)
        @unknown default:
            break
        }
    }
}
