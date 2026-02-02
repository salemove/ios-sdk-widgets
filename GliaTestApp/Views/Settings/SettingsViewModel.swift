import SwiftUI
import GliaWidgets
import GliaCoreSDK

extension SettingsView {
    @MainActor
    final class ViewModel: ObservableObject {
        var appState: AppState

        @Published var siteApiKeyId: String = ""
        @Published var siteApiKeySecret: String = ""
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

        func loadCurrentSettings() {
            let config = appState.configuration

            switch config.authorizationMethod {
            case .siteApiKey(let id, let secret):
                siteApiKeyId = id
                siteApiKeySecret = secret
            default:
                break
            }

            site = config.site
            companyName = config.companyName
            environmentSelection = EnvironmentSelection(from: config.environment)
            if case .custom(let url) = config.environment {
                customEnvironmentUrl = url.absoluteString
            }
            queueId = appState.queueId
            useDefaultQueue = appState.useDefaultQueue

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
    func saveSettings() {
        let env: GliaEnvironment
        if environmentSelection == .custom, let url = URL(string: customEnvironmentUrl) {
            env = .custom(url)
        } else {
            env = environmentSelection.gliaEnvironment
        }

        let uuid = UUID(uuidString: visitorContextAssetId)
        let locale = manualLocaleOverride.isEmpty ? nil : manualLocaleOverride

        appState.configuration = Configuration(
            authorizationMethod: .siteApiKey(
                id: siteApiKeyId,
                secret: siteApiKeySecret
            ),
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
