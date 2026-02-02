import SwiftUI
import GliaWidgets
import Combine
import UIKit

@MainActor
final class AppState: ObservableObject {
    @Published var configuration: Configuration
    @Published var queueId: String
    @Published var useDefaultQueue: Bool
    @Published var theme: Theme
    @Published var features: Features
    @Published var autoConfigureEnabled: Bool
    @Published var authenticationBehavior: Glia.Authentication.Behavior
    @Published var stopPushOnDeauthenticate: Bool
    @Published var isConfigured: Bool = false
    @Published var currentEngagement: EngagementKind?
    @Published var authentication: Glia.Authentication?

    var engagementLauncher: EngagementLauncher?
    var entryWidget: EntryWidget?

    private var cancellables = Set<AnyCancellable>()

    init() {
        self.configuration = UserDefaults.standard.configuration
        self.queueId = UserDefaults.standard.queueId
        self.useDefaultQueue = UserDefaults.standard.useDefaultQueue
        self.theme = Theme()
        self.features = UserDefaults.standard.features
        self.autoConfigureEnabled = UserDefaults.standard.autoConfigureEnabled
        self.authenticationBehavior = UserDefaults.standard.authenticationBehavior
        self.stopPushOnDeauthenticate = UserDefaults.standard.stopPushOnDeauthenticate
    }

    func configure(completion: @escaping (Result<Void, Error>) -> Void) {
        do {
            applyPushNotificationConfig()
            let remoteConfig = getRemoteConfiguration()
            try Glia.sharedInstance.configure(
                with: configuration,
                theme: theme,
                uiConfig: remoteConfig,
                features: features,
                completion: { [weak self] result in
                    DispatchQueue.main.async {
                        switch result {
                        case .success:
                            self?.isConfigured = true
                            self?.setupEngagementLauncher()
                            debugPrint("SDK has been configured")
                            completion(.success(()))
                        case .failure(let error):
                            debugPrint("Error configuring the SDK")
                            debugPrint(error)
                            completion(.failure(error))
                        }
                    }
                }
            )
            // Trigger APNs registration within the same configure flow so token callback reaches SDK in time.
            UIApplication.shared.registerForRemoteNotifications()
        } catch {
            completion(.failure(error))
        }
    }

    func applyPushNotificationConfig() {
        let pushNotifications: Configuration.PushNotifications

        #if DEBUG
        pushNotifications = .sandbox
        #else
        // Mirrors TestingApp behavior for release/testing toggles.
        let enablePushes = ProcessInfo.processInfo.environment["ENABLE_PUSH_NOTIFICATIONS"] == "true"
        pushNotifications = enablePushes ? .production : .disabled
        #endif

        configuration.pushNotifications = pushNotifications

        let pushNotificationsTypes: [PushNotificationsType] = [.start, .message, .end]
        Glia.sharedInstance.pushNotifications.subscribeTo(pushNotificationsTypes)
    }

    private func getRemoteConfiguration() -> RemoteConfiguration? {
        guard UserDefaults.standard.bool(forKey: "useRemoteConfiguration") else {
            return nil
        }
        guard let fileName = UserDefaults.standard.string(forKey: "selectedRemoteConfig"),
              fileName != "None" else {
            return nil
        }
        guard
            let url = Bundle.main.url(forResource: fileName, withExtension: "json", subdirectory: "RemoteConfigurations"),
            let jsonData = try? Data(contentsOf: url),
            let config = try? JSONDecoder().decode(RemoteConfiguration.self, from: jsonData)
        else {
            return nil
        }
        return config
    }

    func startChat() throws {
        try engagementLauncher?.startChat()
    }

    func startAudioCall() throws {
        try engagementLauncher?.startAudioCall()
    }

    func startVideoCall() throws {
        try engagementLauncher?.startVideoCall()
    }

    func startSecureMessaging() throws {
        try engagementLauncher?.startSecureMessaging()
    }

    func endEngagement(completion: @escaping (Result<Void, Error>) -> Void) {
        Glia.sharedInstance.endEngagement { result in
            DispatchQueue.main.async {
                completion(result)
            }
        }
    }

    func clearSession(completion: @escaping (Result<Void, Error>) -> Void) {
        Glia.sharedInstance.clearVisitorSession { result in
            DispatchQueue.main.async {
                completion(result)
            }
        }
    }

    func saveConfiguration() {
        UserDefaults.standard.configuration = configuration
        UserDefaults.standard.queueId = queueId
        UserDefaults.standard.useDefaultQueue = useDefaultQueue
        UserDefaults.standard.features = features
        UserDefaults.standard.autoConfigureEnabled = autoConfigureEnabled
        UserDefaults.standard.authenticationBehavior = authenticationBehavior
        UserDefaults.standard.stopPushOnDeauthenticate = stopPushOnDeauthenticate
    }

    private func setupEngagementLauncher() {
        do {
            let queueIds = useDefaultQueue ? [] : [queueId]
            self.entryWidget = try Glia.sharedInstance.getEntryWidget(queueIds: queueIds)
            self.engagementLauncher = try Glia.sharedInstance.getEngagementLauncher(queueIds: queueIds)
        } catch {
            debugPrint("💥 Failed to setup engagement launcher: \(error)")
        }
    }
}

extension UserDefaults {
    private enum Keys {
        static let configuration = "configuration"
        static let queueId = "queueId"
        static let useDefaultQueue = "useDefaultQueue"
        static let features = "features"
        static let autoConfigureEnabled = "autoConfigureEnabled"
        static let authenticationBehavior = "authenticationBehavior"
        static let stopPushOnDeauthenticate = "stopPushOnDeauthenticate"
    }

    var configuration: Configuration {
        get {
            guard let data = data(forKey: Keys.configuration),
                  let config = try? JSONDecoder().decode(Configuration.self, from: data) else {
                return .empty(with: .beta)
            }
            return config
        }
        set {
            let data = try? JSONEncoder().encode(newValue)
            set(data, forKey: Keys.configuration)
        }
    }

    var queueId: String {
        get { string(forKey: Keys.queueId) ?? "" }
        set { set(newValue, forKey: Keys.queueId) }
    }

    var useDefaultQueue: Bool {
        get {
            guard object(forKey: Keys.useDefaultQueue) != nil else {
                return true
            }
            return bool(forKey: Keys.useDefaultQueue)
        }
        set {
            set(newValue, forKey: Keys.useDefaultQueue)
        }
    }

    var features: Features {
        get {
            guard let rawValue = value(forKey: Keys.features) as? Features.RawValue else {
                return .all
            }
            return Features(rawValue: rawValue)
        }
        set {
            set(newValue.rawValue, forKey: Keys.features)
        }
    }

    var autoConfigureEnabled: Bool {
        get {
            guard object(forKey: Keys.autoConfigureEnabled) != nil else {
                return true
            }
            return bool(forKey: Keys.autoConfigureEnabled)
        }
        set {
            set(newValue, forKey: Keys.autoConfigureEnabled)
        }
    }

    var authenticationBehavior: Glia.Authentication.Behavior {
        get {
            let rawValue = string(forKey: Keys.authenticationBehavior) ?? "forbiddenDuringEngagement"
            return rawValue == "allowedDuringEngagement" ? .allowedDuringEngagement : .forbiddenDuringEngagement
        }
        set {
            let rawValue = newValue == .allowedDuringEngagement ? "allowedDuringEngagement" : "forbiddenDuringEngagement"
            set(rawValue, forKey: Keys.authenticationBehavior)
        }
    }

    var stopPushOnDeauthenticate: Bool {
        get {
            guard object(forKey: Keys.stopPushOnDeauthenticate) != nil else {
                return false
            }
            return bool(forKey: Keys.stopPushOnDeauthenticate)
        }
        set {
            set(newValue, forKey: Keys.stopPushOnDeauthenticate)
        }
    }
}
