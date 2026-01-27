import UIKit
import GliaWidgets

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    lazy var deeplinkService: DeeplinksService = {
        let deepLinksHandlers: [DeeplinksService.Host: DeeplinkHandler.Type] = [
            .configure: ConfigurationDeeplinkHandler.self,
            .widgets: SettingsDeeplinkHandler.self
        ]
        return .init(windowProvider: { [weak self] in self?.window }, handlers: deepLinksHandlers)
    }()

    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        guard scene is UIWindowScene else { return }

        // Window is created by storyboard via scene configuration
        // Handle URL contexts from launch
        if let urlContext = connectionOptions.urlContexts.first {
            deeplinkService.openUrl(urlContext.url, withOptions: [:])
        }

        // Handle configuration URL from environment (for testing)
        handleProcessInfoConfiguration()
    }

    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        guard let urlContext = URLContexts.first else { return }
        deeplinkService.openUrl(urlContext.url, withOptions: [:])
    }

    private func handleProcessInfoConfiguration() {
        guard let configurationUrl = ProcessInfo.processInfo.environment["CONFIGURATION_URL"],
              let url = URL(string: configurationUrl) else {
            return
        }
        debugPrint(configurationUrl)
        deeplinkService.openUrl(url, withOptions: [:])
    }
}
