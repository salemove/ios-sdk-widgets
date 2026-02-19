import Foundation

@MainActor
final class DeeplinksService {
    private let context: DeeplinkContext
    private let handlers: [Host: DeeplinkHandler.Type]

    init(
        appState: AppState,
        showSettings: @MainActor @escaping () -> Void
    ) {
        self.context = DeeplinkContext(appState: appState, showSettings: showSettings)
        self.handlers = [
            .configure: ConfigurationDeeplinkHandler.self,
            .widgets: SettingsDeeplinkHandler.self
        ]
    }

    @discardableResult
    func openUrl(_ url: URL) -> Bool {
        handleDeepLink(url)
    }

    @discardableResult
    private func handleDeepLink(_ link: URL) -> Bool {
        guard let components = URLComponents(url: link, resolvingAgainstBaseURL: false),
              let host = components.host,
              let deeplink = Host(rawValue: host),
              let deeplinkHandler = handlers[deeplink] else {
            debugPrint("URL is not valid. url='\(link.absoluteString)'.")
            return false
        }

        let handler = deeplinkHandler.init(context: context)
        return handler.handleDeeplink(
            with: link.lastPathComponent,
            queryItems: components.queryItems
        )
    }
}

extension DeeplinksService {
    enum Host: String {
        case configure
        case widgets
    }
}
