import SwiftUI
import GliaWidgets
import GliaCoreSDK

extension SettingsView {
    enum AuthorizationMethodSelection: String, CaseIterable {
        case siteApiKey
        case userApiKey
    }

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

    @MainActor
    final class ViewModel: ObservableObject {
        private struct AuthorizationConfigurationProfile {
            let site: String
            let companyName: String
            let queueId: String
            let useDefaultQueue: Bool
        }

        var appState: AppState
        private var lastAuthorizationMethodSelection: AuthorizationMethodSelection = .siteApiKey
        private var isLoadingSettings = false

        @Published var authorizationMethodSelection: AuthorizationMethodSelection = .siteApiKey
        @Published var siteApiKeyId: String = ""
        @Published var siteApiKeySecret: String = ""
        @Published var userApiKeyId: String = ""
        @Published var userApiKeySecret: String = ""
        @Published var site: String = ""
        @Published var companyName: String = ""
        @Published var queueId: String = ""
        @Published var useDefaultQueue: Bool = true
        @Published var environmentSelection: EnvironmentSelection = .beta
        @Published var customEnvironmentUrl: String = ""
        @Published var visitorContextAssetId: String = ""
        @Published var manualLocaleOverride: String = ""
        @Published var suppressPushPermission: Bool = false
        @Published var autoConfigureEnabled: Bool = true
        @Published var authenticationBehavior: Glia.Authentication.Behavior = .forbiddenDuringEngagement
        @Published var stopPushOnDeauthenticate: Bool = false
        @Published var bubbleFeatureEnabled: Bool = true
        @Published var useRemoteConfiguration: Bool = false
        @Published var selectedRemoteConfig: String = "None"

        @Published var themeColors = ThemeColors()
        @Published var themeFonts = ThemeFonts()

        @Published var showQueuePicker = false
        @Published var availableQueues: [GliaWidgets.Queue] = []
        @Published var isLoadingQueues = false
        @Published var queueError: String?

        @Published var showError: AlertData?

        init(appState: AppState) {
            self.appState = appState
        }

        var gliaWidgetsVersion: String {
            StaticValues.sdkVersion
        }

        var gliaCoreSDKVersion: String {
            getFrameworkVersion(for: GliaCoreSDK.PushNotifications.self, frameworkName: "GliaCoreSDK")
        }

        var gliaOpenTelemetryVersion: String {
            getFrameworkVersion(bundleIdentifier: "org.cocoapods.GliaOpenTelemetry")
        }

        private func getFrameworkVersion(for classType: AnyClass, frameworkName: String) -> String {
            let bundle = Bundle(for: classType)
            return extractVersion(from: bundle) ?? "Unknown"
        }

        private func getFrameworkVersion(bundleIdentifier: String) -> String {
            guard let bundle = Bundle(identifier: bundleIdentifier) else {
                return "Unknown"
            }
            return extractVersion(from: bundle) ?? "Unknown"
        }

        private func extractVersion(from bundle: Bundle) -> String? {
            bundle.infoDictionary?["CFBundleShortVersionString"] as? String
        }

        var selectedApiKeyId: String {
            get {
                switch authorizationMethodSelection {
                case .siteApiKey:
                    return siteApiKeyId
                case .userApiKey:
                    return userApiKeyId
                }
            }
            set {
                switch authorizationMethodSelection {
                case .siteApiKey:
                    siteApiKeyId = newValue
                case .userApiKey:
                    userApiKeyId = newValue
                }
            }
        }

        var selectedApiKeySecret: String {
            get {
                switch authorizationMethodSelection {
                case .siteApiKey:
                    return siteApiKeySecret
                case .userApiKey:
                    return userApiKeySecret
                }
            }
            set {
                switch authorizationMethodSelection {
                case .siteApiKey:
                    siteApiKeySecret = newValue
                case .userApiKey:
                    userApiKeySecret = newValue
                }
            }
        }

        var selectedApiKeyIdentifierTitle: String {
            switch authorizationMethodSelection {
            case .siteApiKey:
                return "Site API Key Identifier"
            case .userApiKey:
                return "User API Key Identifier"
            }
        }

        var selectedApiKeySecretTitle: String {
            switch authorizationMethodSelection {
            case .siteApiKey:
                return "Site API Key Secret"
            case .userApiKey:
                return "User API Key Secret"
            }
        }

        private func loadStoredAuthorizationCredentials() {
            siteApiKeyId = UserDefaults.standard.string(
                forKey: AuthorizationCredentialsDefaultsKey.siteApiKeyId
            ) ?? ""
            siteApiKeySecret = UserDefaults.standard.string(
                forKey: AuthorizationCredentialsDefaultsKey.siteApiKeySecret
            ) ?? ""
            userApiKeyId = UserDefaults.standard.string(
                forKey: AuthorizationCredentialsDefaultsKey.userApiKeyId
            ) ?? ""
            userApiKeySecret = UserDefaults.standard.string(
                forKey: AuthorizationCredentialsDefaultsKey.userApiKeySecret
            ) ?? ""
        }

        private func saveStoredAuthorizationCredentials() {
            UserDefaults.standard.set(
                siteApiKeyId,
                forKey: AuthorizationCredentialsDefaultsKey.siteApiKeyId
            )
            UserDefaults.standard.set(
                siteApiKeySecret,
                forKey: AuthorizationCredentialsDefaultsKey.siteApiKeySecret
            )
            UserDefaults.standard.set(
                userApiKeyId,
                forKey: AuthorizationCredentialsDefaultsKey.userApiKeyId
            )
            UserDefaults.standard.set(
                userApiKeySecret,
                forKey: AuthorizationCredentialsDefaultsKey.userApiKeySecret
            )
        }

        private func configurationProfileStorageKeys(
            for selection: AuthorizationMethodSelection
        ) -> (site: String, companyName: String, queueId: String, useDefaultQueue: String) {
            switch selection {
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
            }
        }

        private func saveConfigurationProfile(
            _ profile: AuthorizationConfigurationProfile,
            for selection: AuthorizationMethodSelection
        ) {
            let keys = configurationProfileStorageKeys(for: selection)
            UserDefaults.standard.set(profile.site, forKey: keys.site)
            UserDefaults.standard.set(profile.companyName, forKey: keys.companyName)
            UserDefaults.standard.set(profile.queueId, forKey: keys.queueId)
            UserDefaults.standard.set(profile.useDefaultQueue, forKey: keys.useDefaultQueue)
        }

        private func loadConfigurationProfile(
            for selection: AuthorizationMethodSelection
        ) -> AuthorizationConfigurationProfile {
            let keys = configurationProfileStorageKeys(for: selection)
            let storedUseDefaultQueue: Bool
            if UserDefaults.standard.object(forKey: keys.useDefaultQueue) != nil {
                storedUseDefaultQueue = UserDefaults.standard.bool(forKey: keys.useDefaultQueue)
            } else {
                storedUseDefaultQueue = true
            }
            return AuthorizationConfigurationProfile(
                site: UserDefaults.standard.string(forKey: keys.site) ?? "",
                companyName: UserDefaults.standard.string(forKey: keys.companyName) ?? "",
                queueId: UserDefaults.standard.string(forKey: keys.queueId) ?? "",
                useDefaultQueue: storedUseDefaultQueue
            )
        }

        private func saveCurrentConfigurationProfile(
            for selection: AuthorizationMethodSelection
        ) {
            saveConfigurationProfile(
                AuthorizationConfigurationProfile(
                    site: site,
                    companyName: companyName,
                    queueId: queueId,
                    useDefaultQueue: useDefaultQueue
                ),
                for: selection
            )
        }

        private func applyConfigurationProfile(
            _ profile: AuthorizationConfigurationProfile
        ) {
            site = profile.site
            companyName = profile.companyName
            queueId = profile.queueId
            useDefaultQueue = profile.useDefaultQueue
        }

        func loadCurrentSettings() {
            isLoadingSettings = true
            defer {
                lastAuthorizationMethodSelection = authorizationMethodSelection
                isLoadingSettings = false
            }

            let config = appState.configuration
            loadStoredAuthorizationCredentials()

            let credentials = authorizationCredentials(from: config.authorizationMethod)
            let selection = authorizationSelection(for: credentials.secret)
            authorizationMethodSelection = selection

            switch selection {
            case .siteApiKey:
                siteApiKeyId = credentials.id
                siteApiKeySecret = credentials.secret
            case .userApiKey:
                userApiKeyId = credentials.id
                userApiKeySecret = credentials.secret
            }
            saveStoredAuthorizationCredentials()

            saveConfigurationProfile(
                AuthorizationConfigurationProfile(
                    site: config.site,
                    companyName: config.companyName,
                    queueId: appState.queueId,
                    useDefaultQueue: appState.useDefaultQueue
                ),
                for: selection
            )
            applyConfigurationProfile(
                loadConfigurationProfile(for: selection)
            )

            environmentSelection = EnvironmentSelection(from: config.environment)
            if case .custom(let url) = config.environment {
                customEnvironmentUrl = url.absoluteString
            }

            if let assetId = config.visitorContext?.assetId {
                visitorContextAssetId = assetId.uuidString
            }

            manualLocaleOverride = config.manualLocaleOverride ?? ""
            suppressPushPermission = config.suppressPushNotificationsPermissionRequestDuringAuthentication
            autoConfigureEnabled = appState.autoConfigureEnabled
            authenticationBehavior = appState.authenticationBehavior
            stopPushOnDeauthenticate = appState.stopPushOnDeauthenticate

            bubbleFeatureEnabled = appState.features.contains(.bubbleView)

            useRemoteConfiguration = UserDefaults.standard.bool(forKey: "useRemoteConfiguration")
            selectedRemoteConfig = UserDefaults.standard.string(forKey: "selectedRemoteConfig") ?? "None"

            themeColors = ThemeColors(from: appState.theme)
            themeFonts = ThemeFonts(from: appState.theme)
        }

        private func authorizationCredentials(
            from method: Configuration.AuthorizationMethod
        ) -> (id: String, secret: String) {
            switch method {
            case let .siteApiKey(id, secret), let .userApiKey(id, secret):
                return (id, secret)
            @unknown default:
                return ("", "")
            }
        }

        private func authorizationSelection(for secret: String) -> AuthorizationMethodSelection {
            secret.lowercased().hasPrefix("gls_") ? .siteApiKey : .userApiKey
        }

        func didChangeAuthorizationMethodSelection(
            to selection: AuthorizationMethodSelection
        ) {
            guard !isLoadingSettings else { return }
            guard selection != lastAuthorizationMethodSelection else { return }

            saveStoredAuthorizationCredentials()
            saveCurrentConfigurationProfile(for: lastAuthorizationMethodSelection)
            applyConfigurationProfile(
                loadConfigurationProfile(for: selection)
            )
            lastAuthorizationMethodSelection = selection
        }

        var availableRemoteConfigs: [String] {
            let paths = Bundle.main.paths(forResourcesOfType: "json", inDirectory: "RemoteConfigurations")
            let names = paths
                .compactMap(URL.init(string:))
                .compactMap { url -> String? in
                    url.lastPathComponent.components(separatedBy: ".").first
                }
                .sorted()
            return ["None"] + names
        }

        func getRemoteConfiguration() -> RemoteConfiguration? {
            guard useRemoteConfiguration, selectedRemoteConfig != "None" else {
                return nil
            }
            guard
                let url = Bundle.main.url(forResource: selectedRemoteConfig, withExtension: "json", subdirectory: "RemoteConfigurations"),
                let jsonData = try? Data(contentsOf: url),
                let config = try? JSONDecoder().decode(RemoteConfiguration.self, from: jsonData)
            else {
                return nil
            }
            return config
        }
    }
}

extension SettingsView.ViewModel {
    private var selectedAuthorizationMethod: Configuration.AuthorizationMethod {
        switch authorizationMethodSelection {
        case .siteApiKey:
            return .siteApiKey(
                id: siteApiKeyId,
                secret: siteApiKeySecret
            )
        case .userApiKey:
            return .userApiKey(
                id: userApiKeyId,
                secret: userApiKeySecret
            )
        }
    }

    func saveSettings() {
        let env: GliaEnvironment
        if environmentSelection == .custom, let url = URL(string: customEnvironmentUrl) {
            env = .custom(url)
        } else {
            env = environmentSelection.gliaEnvironment
        }

        let uuid = UUID(uuidString: visitorContextAssetId)
        let locale = manualLocaleOverride.isEmpty ? nil : manualLocaleOverride

        saveStoredAuthorizationCredentials()
        saveCurrentConfigurationProfile(for: authorizationMethodSelection)

        appState.configuration = Configuration(
            authorizationMethod: selectedAuthorizationMethod,
            environment: env,
            site: site,
            visitorContext: uuid.map { Configuration.VisitorContext(assetId: $0) },
            companyName: companyName,
            manualLocaleOverride: locale,
            suppressPushNotificationsPermissionRequestDuringAuthentication: suppressPushPermission
        )

        appState.queueId = queueId
        appState.useDefaultQueue = useDefaultQueue
        appState.autoConfigureEnabled = autoConfigureEnabled
        appState.authenticationBehavior = authenticationBehavior
        appState.stopPushOnDeauthenticate = stopPushOnDeauthenticate

        var features = Features.all
        if !bubbleFeatureEnabled {
            features.remove(.bubbleView)
        }
        appState.features = features

        appState.theme = Theme(
            colorStyle: .custom(themeColors.toThemeColor()),
            fontStyle: .custom(themeFonts.toThemeFont())
        )

        UserDefaults.standard.set(useRemoteConfiguration, forKey: "useRemoteConfiguration")
        UserDefaults.standard.set(selectedRemoteConfig, forKey: "selectedRemoteConfig")

        appState.saveConfiguration()
    }

    func loadQueues() {
        isLoadingQueues = true
        queueError = nil
        showQueuePicker = true

        Glia.sharedInstance.getQueues { [weak self] result in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.isLoadingQueues = false
                switch result {
                case .success(let queues):
                    self.availableQueues = queues.sorted { $0.name < $1.name }
                case .failure(let error):
                    self.queueError = error.localizedDescription
                }
            }
        }
    }
}
