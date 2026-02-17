import UIKit

protocol DeeplinkHandler {
    init(window: UIWindow?)
    func handleDeeplink(
        with path: String?,
        queryItems: [URLQueryItem]?
    ) -> Bool
}

final class DeeplinksService {
    enum Host: String {
        case configure, widgets
    }

    private let window: UIWindow?
    private let handlers: [Host: DeeplinkHandler.Type]

    init(
        window: UIWindow?,
        handlers: [Host: DeeplinkHandler.Type]
    ) {
        self.window = window
        self.handlers = handlers
    }
}

extension DeeplinksService {
    @discardableResult
    func openUrl(
        _ url: URL,
        withOptions options: [UIApplication.OpenURLOptionsKey: Any]
    ) -> Bool {
        return handleDeepLink(url)
    }
}

// MARK: - Private methods

private extension DeeplinksService {
    @discardableResult
    func handleDeepLink(_ link: URL) -> Bool {
        guard let components = URLComponents(url: link, resolvingAgainstBaseURL: false),
              let host = components.host,
              let deeplink = Host(rawValue: host),
              let deeplinkHandler = handlers[deeplink] else {
            debugPrint("URL is not valid. url='\(link.absoluteString)'.")
            return false
        }

        let handler = deeplinkHandler.init(window: window)

        return handler.handleDeeplink(
            with: link.lastPathComponent,
            queryItems: components.queryItems
        )
    }
}

