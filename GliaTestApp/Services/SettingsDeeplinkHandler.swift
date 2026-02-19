import Foundation

struct SettingsDeeplinkHandler: DeeplinkHandler {
    private let context: DeeplinkContext

    init(context: DeeplinkContext) {
        self.context = context
    }

    @MainActor
    func handleDeeplink(
        with path: String?,
        queryItems: [URLQueryItem]?
    ) -> Bool {
        guard path == Path.settings.rawValue else { return false }
        context.showSettings()
        return true
    }
}

extension SettingsDeeplinkHandler {
    enum Path: String {
        case settings
    }
}
