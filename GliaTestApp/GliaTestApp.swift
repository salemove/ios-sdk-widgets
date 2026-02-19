import SwiftUI
import GliaWidgets

typealias GliaEnvironment = GliaWidgets.Environment

@main
struct GliaTestApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate

    @StateObject private var appState = AppState()
    @State private var showSettings = false
    @SwiftUI.Environment(\.scenePhase) private var scenePhase

    private var deeplinkService: DeeplinksService {
        DeeplinksService(
            appState: appState,
            showSettings: { @MainActor in
                showSettings = true
            }
        )
    }

    init() {
        setupGlia()
        handleSetAnimationsEnabled()
    }

    var body: some Scene {
        WindowGroup {
            ContentView(appState: appState, showSettings: $showSettings)
                .colorScheme(.light)
                .sheet(isPresented: $showSettings) {
                    SettingsView()
                        .environmentObject(appState)
                }
                .onOpenURL { url in
                    _ = deeplinkService.openUrl(url)
                }
                .onReceive(NotificationCenter.default.publisher(for: .openDeepLinkURL)) { note in
                    guard let url = note.object as? URL else { return }
                    _ = deeplinkService.openUrl(url)
                }
                .onReceive(NotificationCenter.default.publisher(for: .handlePushNotification)) { _ in
                    handleSecureMessagePush()
                }
                .onChange(of: scenePhase) { newPhase in
                    if newPhase == .active {
                        handleProcessEnvironment()
                    }
                }
        }
    }
}

private extension GliaTestApp {
    func setupGlia() {
        Glia.sharedInstance.pushNotifications.setPushHandler { push in
            switch (push.type, push.timing) {
            case (.chatMessage, .background), (.queueMessage, .background):
                NotificationCenter.default.post(name: .handlePushNotification, object: push)
            default:
                break
            }
        }
    }

    func handleProcessEnvironment() {
        guard let configurationUrl = ProcessInfo.processInfo.environment["CONFIGURATION_URL"],
              let url = URL(string: configurationUrl) else {
            return
        }
        _ = deeplinkService.openUrl(url)
    }

    func handleSetAnimationsEnabled() {
        let env = ProcessInfo.processInfo.environment
        if env["SET_ANIMATION_ENABLED"] == "false" {
            UIView.setAnimationsEnabled(false)
        }
    }

    func handleSecureMessagePush() {
        guard !hasPresentedViewController() else { return }

        let startSecureMessaging = {
            do {
                try appState.startSecureMessaging()
            } catch GliaError.engagementExists {
                try? Glia.sharedInstance.resume()
            } catch {
                debugPrint("💥 Failed to open secure messaging from push. Error: \(error.localizedDescription)")
            }
        }

        if appState.autoConfigureEnabled {
            appState.configure { result in
                switch result {
                case .success:
                    startSecureMessaging()
                case .failure(let error):
                    debugPrint("💥 Failed to configure SDK for push action. Error: \(error.localizedDescription)")
                }
            }
        } else {
            appState.applyPushNotificationConfig()
            startSecureMessaging()
        }
    }

    func hasPresentedViewController() -> Bool {
        UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap(\.windows)
            .contains { $0.rootViewController?.presentedViewController != nil }
    }
}

extension Notification.Name {
    static let handlePushNotification = Notification.Name("handlePushNotification")
    static let openDeepLinkURL = Notification.Name("openDeepLinkURL")
}
