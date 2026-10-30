import Foundation
import GliaWidgets

struct ConfigurationDeeplinkHandler: DeeplinkHandler {
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

        context.appState.configuration = configuration
        context.appState.queueId = queueId ?? ""
        context.appState.useDefaultQueue = useDefaultQueue

        context.appState.saveConfiguration()
        return true
    }
}
