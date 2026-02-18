import UIKit
import GliaWidgets

protocol DeeplinkHandler {
    init(context: DeeplinkContext)
    @MainActor
    func handleDeeplink(with path: String?, queryItems: [URLQueryItem]?) -> Bool
}

struct DeeplinkContext {
    let appState: AppState
    let showSettings: @MainActor () -> Void
}
